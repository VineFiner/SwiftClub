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
        let _ = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])

//        tokenAuthGroup.get("list", use: listNews)
//        tokenAuthGroup.get("newer", use: hasNewerNews)
    }
}

extension NewsRouteController {

//    func listNews(_ request: Request) throws -> Future<Response> {
//
//    }

//    func hasNewerNews(_ request: Request) throws -> Future<Response> {
//        return try News.query(on: request).all()
//    }
}
