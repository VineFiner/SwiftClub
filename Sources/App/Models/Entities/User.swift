//
//  User.swift
//  App
//
//  Created by laijihua on 2018/5/31.
//

import Vapor
import FluentPostgreSQL
import Authentication
import Pagination

/// 用户表
struct User: Content {
    var id: Int?
    var name: String
    var email: String?
    var avator: String?
    var info: String? // 简介

    var phone: String? // 手机
    var wechat: String? // 微信账号
    var qq: String? // qq 账号
    var github: String? // github 账号
    var website: String? // 个人主页
    var weibo: String? // 微博
    var location: String? // 坐标

    var role: Int // 用户角色
    var state: Int // 用户状态
    var loginedAt: Date? // 最后登入时间

    var createdAt: Date? // 注册时间
    var updatedAt: Date? // 更新时间

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }

    init(name: String,
         phone: String? = nil,
         email: String? = nil,
         avator: String? = nil,
         info: String? = nil,
         role: RoleType = .member,
         state: UserState = .normal) {
        self.name = name
        self.phone = phone
        self.email = email
        self.avator = avator
        self.info = info ?? "暂无简介"
        self.role = role.rawValue
        self.state = state.rawValue
    }
}

extension User: PostgreSQLModel {}
extension User: Migration {}

extension User{
    enum RoleType: Int {
        case member = 1
        case admin = 2
        case master = 3
    }
    enum UserState: Int {
        case normal = 1
        case disable = 2
        case delete = 3
    }
}

extension User {

    var codes: Children<User, ActiveCode> {
        return children(\.userId)
    }
}

extension User: Paginatable {}
extension User: Parameter {}

//MARK: TOkenAuthenticatable
extension User: TokenAuthenticatable {
    typealias TokenType = AccessToken
}

