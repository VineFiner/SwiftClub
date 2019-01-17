//
//  Notify.swift
//  App
//
//  Created by laijihua on 2018/8/27.
//

import Vapor
import FluentPostgreSQL
import Pagination

/// 产生一条记录, 「小明喜欢了文章」,
/// Remind
// target = 123,  // 文章ID
// targetType = 'post',  // 指明target所属类型是文章
// senderId = 123456  // 小明ID

/// Save Announce and Message
// 它们会用到 content 字段，而不会用到 target、targetType、action 字段

final class Notify: Content {
    var id: Int?
    var content: String?  // 消息的内容
    var type: Int // 消息的类型，1: 公告 Announce，2: 提醒 Remind，3：信息 Message
    var target: Int?  // 目标 id
    var targetType: String? // 目标的类型
    var action: String? // 提醒信息的动作类型
    var senderId: User.ID?  // 发送者的ID

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(type: Int,
         target:Int? = nil,
         targetType: String? = nil,
         action: String? = nil,
         sender: User.ID? = nil,
         content: String? = nil){
        self.type = type
        self.target = target
        self.targetType = targetType
        self.action = action
        self.senderId = sender
        self.content = content
    }
}

extension Notify {
    static var announce: Int {return 1}
    static var remind: Int {return 2}
    static var message: Int {return 3}
}

extension Notify {
    var userNotifis: Children<Notify,UserNotify> {
        return children(\UserNotify.notifyId)
    }
}

extension Notify: Paginatable {}
extension Notify: Migration {}
extension Notify: PostgreSQLModel {}



