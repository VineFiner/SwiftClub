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
        /// comment
    }
}

extension InformationController {
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
