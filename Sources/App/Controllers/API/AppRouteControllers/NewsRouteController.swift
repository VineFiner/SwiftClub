//
//  NewsRouteController.swift
//  App
//
//  Created by laijihua on 2018/6/27.
//

import Vapor
import FluentPostgreSQL

final class NewsRouteController: RouteCollection {

    let notifyService = NotifyService()
    
    func boot(router: Router) throws {
        let group = router.grouped("api", "news")
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])

        tokenAuthGroup.get("dynamic", use: listNews) // 用户动态， 我主动的操作
        tokenAuthGroup.get("list", use: listNews) // 用户消息，订阅的事件，被动的
    }
}

extension NewsRouteController {
    /// 包含分页
    func listNews(_ request: Request) throws -> Future<Response> {
        let _ = try request.authenticated(User.self)
        let userId = try request.query.get(Int.self, at: "userId")
        return try self.notifyService.getUserNotify(userId: userId, on: request)
    }
}
