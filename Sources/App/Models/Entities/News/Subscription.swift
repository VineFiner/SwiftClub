//
//  Subscription.swift
//  App
//
//  Created by laijihua on 2018/8/27.
//
import Vapor
import FluentPostgreSQL
/// 订阅，是从Notify表拉取消息到UserNotify的前提，用户首先订阅了某一个目标的某一个动作，在此之后产生这个目标的这个动作的消息，才会被通知到该用户。
// 「小明关注了产品A的评论」
// target: 123,  // 产品A的ID
// targetType: 'product',
// action: 'comment',
// user: 123  // 小明的ID

final class Subscription: Content {
    var id: Int?
    var target: Int
    var targetType: String
    var userId: User.ID
    var action: String

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(target: Int, targetType: String, userId: User.ID, action: String) {
        self.target = target
        self.targetType = targetType
        self.userId = userId
        self.action = action
    }
}

extension Subscription: Migration {}
extension Subscription: PostgreSQLModel {}
