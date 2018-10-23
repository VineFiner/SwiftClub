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

extension Array {
    func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
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
        let response = try request.parameters.next(Topic.self).flatMap(to: [TopicCommentContainer].self) { topic in
            let topicId = try topic.requireID()
            let tuples = Comment.query(on: request)
                .filter(\Comment.topicId == topicId)   // 刷选出这个评论
                .join(\Replay.commentId, to: \Comment.id)  //
                .alsoDecode(Replay.self)
                .all()
            let result = tuples.map { self.handleTupleComment(tuples: $0)}
            return result
        }
        return try response.makeJson(on:request)
    }


    func handleTupleComment(tuples: [(Comment, Replay)]) -> [TopicCommentContainer] {
        let items = tuples.map { tuple in
            return TopicCommentContainer(comment: tuple.0, replays: [tuple.1])
        }
        // 找出评论 id
        let comms = items.filterDuplicates({$0.comment.id})
        for var tmp in items {
            for res in comms {
                if res.comment.id == tmp.comment.id {
                    tmp.replays.append(contentsOf: res.replays)
                }
            }
        }
        return comms
    }

    func subjectsList(request: Request) throws -> Future<Response> {
        return try Subject.query(on: request).all().makeJson(on: request)
    }

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
        return try Topic
            .query(on: request)
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

