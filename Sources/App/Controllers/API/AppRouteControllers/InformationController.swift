//
//  InformationController.swift
//  App
//
//  Created by laijihua on 2018/12/19.
//

import Vapor
import FluentPostgreSQL
import Pagination

final class InformationController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("api", "information")
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])

        /// list
        group.get("/", use: listInfomartion)
        /// create
        tokenAuthGroup.post(Infomation.self, at: "/", use: createInfomation)
        /// comment
        group.get(Infomation.parameter, "comments", use: listInfomationComments)
        tokenAuthGroup.post(Replay.self, at: "comment", "replay", use: commentAddReplay)
        tokenAuthGroup.post(InformationCommentReqContainer.self, at:"comment", use: informationAddComment)
    }
}

extension InformationController {
    func createInfomation(on request: Request, container: Infomation) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return try container.create(on: request).makeJson(on: request)
    }

    // 添加评论回复
    func commentAddReplay(request: Request, replay: Replay) throws  -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return try replay.create(on: request).makeJson(on: request)
    }
    // 添加评论
    func informationAddComment(request: Request, container: InformationCommentReqContainer) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        let comment = Comment(targetType:.information, targetId: container.informationId, userId: container.userId, content: container.content)
        return try comment.create(on: request).makeJson(on: request)
    }

    func listInfomationComments(on request: Request) throws -> Future<Response> {
        return try request
            .parameters
            .next(Infomation.self)
            .flatMap { information in
                let informationId = try information.requireID()
                return try Comment
                    .query(on: request)
                    .filter(\Comment.targetType == CommentType.information.rawValue)
                    .filter(\Comment.targetId == informationId)
                    .range(request.pageRange)
                    .join(\User.id, to: \Comment.userId)
                    .alsoDecode(User.self)
                    .all()
                    .map { tuples in
                        return tuples.map { InformationCommentResContainer(comment: $0.0, user: $0.1) }
                    }.flatMap { comments in
                        return comments.map { comment in
                            return self.fetchCommentContainer(on: request, comment: comment)
                            }.flatten(on: request)
                    }.flatMap { results in
                        return Comment.query(on: request)
                            .filter(\Comment.targetType == CommentType.information.rawValue)
                            .filter(\Comment.targetId == informationId)
                            .count()
                            .map(to: Paginated<InformationFullCommentResContainer>.self) { count in
                                return request.paginated(data: results, total: count)
                        }
                    }.makeJson(on:request)
        }
    }

    func fetchCommentContainer(on request: Request, comment: InformationCommentResContainer) -> Future<InformationFullCommentResContainer> {
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
                return InformationFullCommentResContainer(comment: comment, replays: results)
        }
    }

    func listInfomartion(on request: Request) throws -> Future<Response> {
         return try Infomation
            .query(on: request)
            .sort(\Infomation.createdAt, PostgreSQLDirection.descending)
            .range(request.pageRange)
            .join(\User.id, to: \Infomation.creatorId)
            .alsoDecode(User.self)
            .all()
            .map(to: [InformationResContainer].self, { infos in
                return infos.map { tuple in
                    return InformationResContainer(info: tuple.0, creator: tuple.1)
                }
            }).flatMap { results in
                return Infomation
                    .query(on: request)
                    .count()
                    .map(to: Paginated<InformationResContainer>.self) { count in
                    return request.paginated(data: results, total: count)
                }
            }.makeJson(on:request)
    }

}
