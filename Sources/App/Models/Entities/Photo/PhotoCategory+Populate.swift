//
//  PhotoCategory+Populate.swift
//  App
//
//  Created by laijihua on 2018/10/30.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class PopulatePhotoCategoryForms: Migration {
    typealias Database = PostgreSQLDatabase

    static let cates: [String] = [
        "人像",
        "风景",
        "生态",
        "纪实",
        "生活",
        "夜景",
        "LOMO",
        "商业",
        "妆型",
        "宠物",
        "运动",
        "观念",
        "儿童",
        "汽车",
        "潜水",
        "航拍",
        "手机摄影",
        "其他"
    ]

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        let futures = cates.map { name in
            return PhotoCategory(name: name).create(on: conn).map(to: Void.self, {_ in })
        }
        return Future<Void>.andAll(futures, eventLoop: conn.eventLoop)
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        let futures = cates.map { name in
            return PhotoCategory.query(on: conn).filter(\.name == name).delete()
        }
        return Future<Void>.andAll(futures, eventLoop: conn.eventLoop)
    }
    
}
