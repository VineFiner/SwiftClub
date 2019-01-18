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

    let notifyService = NotifyService()

    func boot(router: Router) throws {
        let group = router.grouped("api", "topic")
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])

        group.get("subjects", use: subjectsList) // 获取板块
        group.get("list", use: topicList) // 获取话题列表
        group.get(Topic.parameter, use: topicFetch) // topic 详情
        group.get(Topic.parameter, "comments", use: topicComments)

        tokenAuthGroup.post(Collect.self, at:"collect", use: topicCollect)
        tokenAuthGroup.post(Collect.self, at:"uncollect", use: topicUncollect)

        tokenAuthGroup.post(TopicCommentReqContainer.self, at:"comment", use: topicAddComment)
        tokenAuthGroup.post(Replay.self, at: "comment", "replay", use: commentAddReplay)
        tokenAuthGroup.post(Topic.self, at: "add", use: topicAdd)
    }
}


extension TopicRouteController {

    func topicUncollect(request: Request, container: Collect) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return Collect.query(on: request)
            .filter(\Collect.targetType == container.targetType)
            .filter(\Collect.targetId == container.targetId)
            .filter(\Collect.collectorId == container.collectorId)
            .delete()
            .flatMap { _ in
                return try self.notifyService.cancelSubscription(userId: container.collectorId, target: container.targetId, targetType: .topic, on: request)
            }
    }

    func topicCollect(request: Request, container: Collect) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return try container
            .create(on: request)
            .flatMap { collect -> EventLoopFuture<Collect> in // 且被添加订阅
                let futrz = try self.notifyService.subscribe(userId: collect.collectorId, target: collect.targetId, targetType: .topic , reason: .likeTopic, on: request)
                let futera = try self.notifyService.createRemind(target: collect.targetId, targetType: .topic, action: .like, sender: collect.collectorId, content: "收藏", on: request)
                return map(futrz, futera, { a, b in
                    return collect
                })
            }.makeJson(on: request)
    }

    // 添加评论回复
    func commentAddReplay(request: Request, replay: Replay) throws  -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return try replay.create(on: request).makeJson(on: request)
    }

    // 添加评论
    func topicAddComment(request: Request, container: TopicCommentReqContainer) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        let comment = Comment(targetId: container.topicId, userId: container.userId, content: container.content)
        return comment
            .create(on: request)
            .flatMap { comment in

                /// 如果是关注了博客就commented， 如果关注了用户就是 .comment
                return try self.notifyService.createRemind(target: comment.targetId, targetType: .topic, action: .comment, sender: comment.userId, content: comment.content, on: request)
            }
    }

    // 获取话题的评论数据， 不支持左连接
    func topicComments(request: Request) throws -> Future<Response> {
        return try request
            .parameters
            .next(Topic.self)
            .flatMap { topic in
                let topicId = try topic.requireID()
                return try Comment
                    .query(on: request)
                    .filter(\Comment.targetType == CommentType.topic.rawValue)
                    .filter(\Comment.targetId == topicId)
                    .range(request.pageRange)
                    .all()
                    .flatMap(to: [CommentResContainer].self, { comments in
                        let commentFetures = comments.map { comment in
                            return User.find(comment.userId, on: request)
                                .unwrap(or: ApiError.init(code: .modelExisted))
                                .map { user in
                                    return CommentResContainer(comment: comment, user: user)
                                }
                        }
                        return commentFetures.flatten(on: request)
                    })
                    .flatMap { comments in
                        return comments.map { comment in
                            return self.fetchCommentContainer(on: request, comment: comment)
                        }.flatten(on: request)
                    }.flatMap { results in
                        return Comment.query(on: request)
                            .filter(\Comment.targetType == CommentType.topic.rawValue)
                            .filter(\Comment.targetId == topicId)
                            .count()
                            .map(to: Paginated<FullCommentResContainer>.self) { count in
                            return request.paginated(data: results, total: count)
                        }
                    }.makeJson(on:request)
        }
    }

    func fetchCommentContainer(on request: Request, comment: CommentResContainer) -> Future<FullCommentResContainer> {
        return Replay
            .query(on: request)
            .filter(\Replay.commentId == comment.id!)
            .all()
            .flatMap { replays in
                return replays.map { replay in
                    return map(User.find(replay.userId, on: request), User.find(replay.toUid, on: request), { user, toUser in
                        return CommentReplayResContainer(replay: replay, user:user!, toUser: toUser!)
                    })
                }.flatten(on: request)
            }.map { results in
                return FullCommentResContainer(comment: comment, replays: results)
            }
    }

    /// 获取主题列表
    func subjectsList(request: Request) throws -> Future<Response> {
        return try Subject.query(on: request).all().makeJson(on: request)
    }

    /// 获取话题
    func topicFetch(request: Request) throws -> Future<Response> {
        return try request.parameters.next(Topic.self).flatMap(to: TopicResContainer.self) { topic in
            return topic
                .creator
                .query(on: request)
                .first()
                .unwrap(or: ApiError(code: .modelNotExist))
                .map(to: TopicResContainer.self) { user in
                return TopicResContainer(topic: topic, user: user)
            }
        }.makeJson(on:request)
    }


    func topicList(request: Request) throws -> Future<Response> {
        let subjectId = try request.query.get(Int?.self, at: "subjectId")
        if let subjectId = subjectId, subjectId > 1 {  // 1 是全部
            return try Topic
                .query(on: request)
                .filter(\Topic.subjectId == subjectId)
                .sort(\Topic.createdAt, .descending)
                .range(request.pageRange) // 获取分页数据
                .join(\User.id, to: \Topic.userId)
                .alsoDecode(User.self)
                .all()
                .map { tuples in
                    return tuples.map { tuple in  return TopicResContainer(topic: tuple.0, user: tuple.1)}
                }.flatMap{ results in
                    return Topic.query(on: request).filter(\Topic.subjectId == subjectId).count().map(to: Paginated<TopicResContainer>.self) { count in
                        return request.paginated(data: results, total: count)
                    }
                }
                .makeJson(on:request)
        } else { // 全部数据
            return try Topic
                .query(on: request)
                .sort(\Topic.createdAt, .descending)
                .range(request.pageRange) // 获取分页数据
                .join(\User.id, to: \Topic.userId)
                .alsoDecode(User.self)
                .all()
                .map { tuples in
                    return tuples.map { tuple in  return TopicResContainer(topic: tuple.0, user: tuple.1)}
                }.flatMap{ results in
                    return Topic.query(on: request).count().map(to: Paginated<TopicResContainer>.self) { count in
                        return request.paginated(data: results, total: count)
                    }
                }
                .makeJson(on:request)
        }
    }

    func topicAdd(request: Request, container: Topic) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self) // 获取到当前用户
        return container
            .create(on: request)
            .flatMap { topic in
                /// xxx发布了 这个 xxx topic，标题是 xxx
                return try self.notifyService.createRemind(target: topic.id!, targetType: .topic, action: .post, sender: topic.userId, content: topic.title, on: request)
            }
    }
}

