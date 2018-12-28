//
//  Visit.swift
//  App
//
//  Created by laijihua on 2018/12/19.
//


import Vapor
import FluentPostgreSQL

enum VisitType: Int {
    case topic = 0
    case information = 1
    case question = 2
}
/// 浏览表
struct Visit: Content {
    var id: Int?
    var targetId: Int
    var targetType: Int
    var vistorId: User.ID
    var createdAt: Date?
    var updatedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
}


extension Visit: PostgreSQLModel {}
extension Visit: Migration {}

