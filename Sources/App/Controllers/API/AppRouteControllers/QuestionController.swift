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
    func boot(router: Router) throws {
        let group = router.grouped("api", "question")
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])
        /// list
        group.get("/", use: listQuestions)
        // desc
        group.get(Question.parameter, use: fetchQuestion)
        /// create
        tokenAuthGroup.post(Question.self, at: "/", use: creatQuestion)
        /// comment
        tokenAuthGroup.post(Replay.self, at: "comment", "replay", use: commentAddReplay)
        tokenAuthGroup.post(QuestionCommentReqContainer.self, at:"comment", use: questionAddComment)
    }
}

extension QuestionController {

    // 添加评论回复
    func commentAddReplay(request: Request, replay: Replay) throws  -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return try replay.create(on: request).makeJson(on: request)
    }

    // 添加评论
    func questionAddComment(request: Request, container: QuestionCommentReqContainer) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        let comment = Comment(targetType:.question, targetId: container.questionId, userId: container.userId, content: container.content)
        return try comment.create(on: request).makeJson(on: request)
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
        return try question.create(on: request).makeJson(on: request)
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
