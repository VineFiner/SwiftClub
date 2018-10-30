//
//  PhtotoComment.swift
//  App
//
//  Created by laijihua on 2018/10/28.
//

import Vapor
import FluentPostgreSQL

/// 图片评论
struct PhotoComment: Content {
    var id: Int?
    var userId: User.ID
    var userAvator: String?
    var userName: String
    var content: String
    var likenum: Int // 点赞数
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }
}

extension PhotoComment: Migration {}
extension PhotoComment: PostgreSQLModel {}
