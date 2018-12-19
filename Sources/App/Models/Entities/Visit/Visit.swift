//
//  Visit.swift
//  App
//
//  Created by laijihua on 2018/12/19.
//


import Vapor
import FluentPostgreSQL

/// 浏览表
struct Visit: Content {
    var id: Int?
    var targetId: Int
    var targetType: VisitType
    var vistorId: User.ID
    var createdAt: Date?
    var updatedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
}

extension Visit {
    enum VisitType: Int, PostgreSQLEnum {
        case topic = 0
        case question = 1
    }
}

extension Visit: PostgreSQLModel {}
extension Visit: Migration {}

