//
//  TopicRouteController.swift
//  App
//
//  Created by laijihua on 2018/10/17.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL
import Pagination


final class TopicRouteController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("api", "topic")
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])

        group.get("subjects", use: subjectsList) // 获取板块
        group.get("list", use: topicList) // 获取话题列表
        group.get(Topic.parameter, use: topicFetch) // topic 详情
        group.get(Topic.parameter, "comments", use: topicComments)

        tokenAuthGroup.post(Comment.self, at:"comment", use: topicAddComment)
        tokenAuthGroup.post(Replay.self, at: "comment", "replay", use: commentAddReplay)
        tokenAuthGroup.post(Topic.self, at: "add", use: topicAdd)
    }
}


extension TopicRouteController {

    // 添加评论回复
    func commentAddReplay(request: Request, replay: Replay) throws  -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return try replay.create(on: request).makeJson(on: request)
    }

    // 添加评论
    func topicAddComment(request: Request, comment: Comment) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return try comment.create(on: request).makeJson(on: request)
    }

    // 获取话题的评论数据
    func topicComments(request: Request) throws -> Future<Response> {
        let response = try request.parameters.next(Topic.self).flatMap(to: Paginated<TopicCommentContainer>.self) { topic in
            let topicId = try topic.requireID()
            let comments = Comment.query(on: request).filter(\Comment.topicId == topicId).range(request.pageRange).all()

            let res = comments.flatMap(to: [TopicCommentContainer].self, { comments  in
                let replysFutures = comments.map { comment in
                    return Replay.query(on: request).filter(\Replay.commentId == comment.id!).all().and(result: comment).map({ tuples in
                        return TopicCommentContainer(comment: tuples.1, replays: tuples.0)
                    })
                }
                return replysFutures.flatten(on: request)
            })
            let result = res.flatMap { results in
                return Comment.query(on: request).count().map(to: Paginated<TopicCommentContainer>.self) { count in
                    return request.paginated(data: results, total: count)
                }
            }

            return result
        }
        return try response.makeJson(on:request)
    }

    /// 获取主题列表
    func subjectsList(request: Request) throws -> Future<Response> {
        return try Subject.query(on: request).all().makeJson(on: request)
    }

    /// 获取话题
    func topicFetch(request: Request) throws -> Future<Response> {
        return try request.parameters.next(Topic.self).flatMap(to: TopicContainer.self) { topic in
            return topic
                .creator
                .query(on: request)
                .first()
                .unwrap(or: ApiError(code: .modelNotExist))
                .map(to: TopicContainer.self) { user in
                return TopicContainer(topic: topic, user: user)
            }
        }.makeJson(on:request)
    }

    func topicList(request: Request) throws -> Future<Response> {
        let subjectId = try request.query.get(Int?.self, at: "subjectId") ?? 1
        return try Topic
            .query(on: request)
            .filter(\Topic.subjectId == subjectId)
            .sort(\Topic.createdAt, .descending)
            .range(request.pageRange) // 获取分页数据
            .join(\User.id, to: \Topic.userId)
            .alsoDecode(User.self)
            .all()
            .map { tuples in
                return tuples.map { tuple in  return TopicContainer(topic: tuple.0, user: tuple.1)}
            }.flatMap{ results in
                return Topic.query(on: request).count().map(to: Paginated<TopicContainer>.self) { count in
                    return request.paginated(data: results, total: count)
                }
            }
            .makeJson(on:request)
    }

    func topicAdd(request: Request, container: Topic) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self) // 获取到当前用户
        return try container
            .create(on: request)
            .makeJson(on: request)
    }
}

