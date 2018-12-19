//
//  QuestionController.swift
//  App
//
//  Created by laijihua on 2018/12/19.
//


import Vapor
import FluentPostgreSQL

final class QuestionController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("api", "question")
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])

        /// list
        /// create
        /// comment

        
    }
}

extension QuestionController {

}
