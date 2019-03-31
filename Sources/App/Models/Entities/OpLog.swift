//
//  Log.swift
//  App
//
//  Created by laijihua on 2018/7/12.
//

import Vapor
import FluentPostgreSQL

// 操作日志表
final class OpLog: Content {
    var id: Int?
    var action: String // 操作事件
    var ip: String // 操作人 ip
    var userId: User.ID //  操作用户
    var userAgent: String // 操作人 UA

    var createdAt: Date? // 操作时间
    static var createdAtKey: TimestampKey? { return \.createdAt }

    init(action:Action, userId: User.ID, ip:String, userAgent: String) {
        self.action = action.rawValue
        self.ip = ip
        self.userId = userId
        self.userAgent = userAgent
    }
}

extension OpLog {
    enum Action: String {
        case DISABLE_USER = "禁用用户"
        case ENABLE_USER = "启用用户: %s"
        case SET_ADMIN = "设置用户为管理员: %s"
        case REMOVE_ADMIN = "取消用户为管理员: %s"
        case SAVE_TOPIC = "发布帖子: %s"
        case LOCK_TOPIC = "锁定帖子: %s"
        case UNLOCK_TOPIC = "解锁帖子: %s"
        case DELETE_TOPIC = "删除帖子: %s"
        case COMMENT_TOPIC = "评论帖子: %s"
        case LOVE_TOPIC = "点赞帖子: %s"
        case UNLOVE_TOPIC = "取消点赞帖子: %s"
        case COLLECT_TOPIC = "收藏帖子: %s"
        case UNCOLLECT_TOPIC = "取消收藏帖子: %s"
        case SETTING_PROFILE = "设置个人信息"
        case UPLOAD_AVATAR = "上传头像"
        case STOP_USER = "停用用户: %s"
        case EDIT_NODE = "编辑节点"
        case ADD_NODE = "新增节点: %s"
        case REGISTER = "用户注册"
        case LOGIN = "登录站点"
        case LOGOUT = "退出站点"
    }
}

extension OpLog {
    var user: Parent<OpLog, User> {
        return parent(\.userId)
    }
}

extension OpLog: Migration {

    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userId, to: \User.id)
        }
    }
}
extension OpLog: PostgreSQLModel {}
