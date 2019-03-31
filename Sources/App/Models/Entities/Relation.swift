//
//  Relation.swift
//  App
//
//  Created by laijihua on 2019/3/10.
//

import Vapor
import FluentPostgreSQL

struct Relation: Content {
    var id: Int?
    var uid: User.ID
    var eventId: Int // 事件 ID
    var relateType: Int // 关系类型

    var createdAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }

    init(uid: User.ID, eventId: Int, relateType: RelateType) {
        self.uid = uid
        self.eventId = eventId
        self.relateType = relateType.rawValue
    }
}

extension Relation {
    enum RelateType: Int {
        case love = 1
        case collect = 2
        case follow = 3
        case browser = 4
    }
}

extension Relation: PostgreSQLModel {}
extension Relation: Migration {}
