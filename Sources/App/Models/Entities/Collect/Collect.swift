//
//  Collect.swift
//  App
//
//  Created by laijihua on 2019/1/18.
//



import Vapor
import FluentPostgreSQL

enum CollectType: String {
    case topic
    case question
}

/// 收藏表
struct Collect: Content {
    var id: Int?
    var collectorId: User.ID
    var targetId: Int // 收藏物主键
    var targetType: String // 收藏物类型 CollectType

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(userId: User.ID, targetType:CollectType, targetId: Int) {
        self.collectorId = userId;
        self.targetType = targetType.rawValue
        self.targetId = targetId
    }
}

extension Collect: Migration {}
extension Collect: PostgreSQLModel {}
