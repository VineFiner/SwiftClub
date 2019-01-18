//
//  QuestionController.swift
//  App
//
//  Created by laijihua on 2018/12/19.
//


import Vapor
import FluentPostgreSQL
import Pagination

final class QuestionController: RouteCollection {
    let notifyService = NotifyService()
    func boot(router: Router) throws {
        let group = router.grouped("api", "question")
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])
        /// list
        group.get("/", use: listQuestions)
        // desc
        group.get(Question.parameter, use: fetchQuestion)
        /// comment
        group.get(Question.parameter, "comments", use: listQuestionComments)
        /// create
        tokenAuthGroup.post(Question.self, at: "/", use: creatQuestion)
        /// comment
        tokenAuthGroup.post(Replay.self, at: "comment", "replay", use: commentAddReplay)
        tokenAuthGroup.post(QuestionCommentReqContainer.self, at:"comment", use: questionAddComment)
    }
}

extension QuestionController {

    func listQuestionComments(request: Request) throws -> Future<Response> {
        return try request
            .parameters
            .next(Question.self)
            .flatMap { question in
                let questionId = try question.requireID()
                return try Comment
                    .query(on: request)
                    .filter(\Comment.targetType == CommentType.question.rawValue)
                    .filter(\Comment.targetId == questionId)
                    .range(request.pageRange)
                    .join(\User.id, to: \Comment.userId)
                    .alsoDecode(User.self)
                    .all()
                    .map { tuples in
                        return tuples.map { CommentResContainer(comment: $0.0, user: $0.1) }
                    }.flatMap { comments in
                        return comments.map { comment in
                            return self.fetchCommentContainer(on: request, comment: comment)
                            }.flatten(on: request)
                    }.flatMap { results in
                        return Comment.query(on: request)
                            .filter(\Comment.targetType == CommentType.question.rawValue)
                            .filter(\Comment.targetId == questionId)
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

    // 添加评论回复
    func commentAddReplay(request: Request, replay: Replay) throws  -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return try replay.create(on: request).makeJson(on: request)
    }

    // 添加评论
    func questionAddComment(request: Request, container: QuestionCommentReqContainer) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        let comment = Comment(targetType:.question, targetId: container.questionId, userId: container.userId, content: container.content)
        return try comment.create(on: request)
            .flatMap (to: Comment.self,{ comment in
                /// xxx 用户评论了xxx问题，评论内容是 xxx
                let futera = try self.notifyService.createRemind(target: comment.targetId, targetType: .question, action: .comment, sender: comment.userId, content: comment.content, on: request)

                /// 这个xx问题被xx评论了，评论内容是xxx
                let futerb = try self.notifyService.createRemind(target: comment.targetId, targetType: .question, action: .commented, sender: comment.userId, content: comment.content, on: request)

                return map(futera, futerb, { a, b in
                    return comment
                })
            }).makeJson(on: request)
    }

    func fetchQuestion(_ reqeust: Request) throws -> Future<Response> {
        return try reqeust.parameters.next(Question.self).flatMap(to: QuestionResContainer.self, { question in
            return question.creator.query(on: reqeust)
                .first()
                .unwrap(or: ApiError(code: .modelExisted))
                .flatMap(to: QuestionResContainer.self, { user in
                    return Comment.query(on: reqeust)
                        .filter(\Comment.targetType == CommentType.question.rawValue)
                        .filter(\Comment.targetId == question.id!)
                        .count().map(to: QuestionResContainer.self, { count in
                            return QuestionResContainer(user: user, question: question, commentCount: count)
                        })
                })
        }).makeJson(on: reqeust)
    }

    func creatQuestion(_ request: Request, question: Question) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return question.create(on: request).flatMap { quest in
            /// xxx发布了 这个 xxx topic，标题是 xxx
            return try self.notifyService.createRemind(target: quest.id!, targetType: .question, action: .post, sender: quest.creatorId, content: quest.title, on: request)
        }
    }

    func listQuestions(_ requst: Request) throws -> Future<Response> {
        return try Question
            .query(on: requst)
            .sort(\Question.createdAt, PostgreSQLDirection.descending)
            .range(requst.pageRange)
            .all()
            .flatMap(to: [QuestionResContainer].self, { questions in
                let futures = questions.map { question in
                    return User.find(question.creatorId, on: requst)
                        .unwrap(or: ApiError(code: .modelNotExist))
                        .flatMap { user in
                        return Comment.query(on: requst)
                            .filter(\Comment.targetType == CommentType.question.rawValue)
                            .filter(\Comment.targetId == question.id!)
                            .count()
                            .map(to: QuestionResContainer.self, { count in
                                return QuestionResContainer(user: user, question: question, commentCount: count)
                            })
                    }
                }
                return futures.flatten(on: requst)
            }).flatMap { results in
                return Question
                    .query(on: requst)
                    .count()
                    .map(to: Paginated<QuestionResContainer>.self) { count in
                        return requst.paginated(data: results, total: count)
                }
            }.makeJson(on: requst)
    }

}
