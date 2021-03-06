//
//  AccountRouteController.swift
//  App
//
//  Created by laijihua on 2018/6/20.
//

import Vapor
import FluentPostgreSQL

final class AccountRouteController: RouteCollection {

    func boot(router: Router) throws {
        let group = router.grouped("account")
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])
        tokenAuthGroup.get("info", use: getAcccountInfo)
        tokenAuthGroup.post(UserUpdateReqContainer.self, at:"update", use: updateAccountInfo)
    }
}

extension AccountRouteController {

    func updateAccountInfo(_ request: Request, container: UserUpdateReqContainer) throws -> Future<Response> {
        var user = try request.requireAuthenticated(User.self)
        user.avator = container.avator ?? user.avator
        user.name = container.name ?? user.name
        user.phone = container.phone ?? user.phone
        user.info = container.info ?? user.info
        return try user.update(on: request).makeJson(on: request)
    }

    func getAcccountInfo(_ request: Request) throws -> Future<Response> {
        let user = try request
            .requireAuthenticated(User.self)
        return try request.makeJson(user)
    }
}

