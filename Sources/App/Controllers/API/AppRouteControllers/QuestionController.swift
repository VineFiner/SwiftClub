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

        /// create
        tokenAuthGroup.post(Question.self, at: "/", use: creatQuestion)
        /// comment
        
        
    }
}

extension QuestionController {

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
                    return User.find(question.creatorId, on: requst).unwrap(or: ApiError(code: .modelNotExist)).map { user in
                        return QuestionResContainer(user: user, question: question)
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
