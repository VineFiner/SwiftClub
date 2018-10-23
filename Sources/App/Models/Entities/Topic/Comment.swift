//
//  Comment.swift
//  App
//
//  Created by laijihua on 2018/10/22.
//

import Vapor
import FluentPostgreSQL

/// 评论表， 设计为二级评论表
struct Comment: Content {
    var id: Int?
    var userId: User.ID  // 评论人
    var userName: String?  // 评论人名字
    var userAvator: String? // 评论人图片
    var topicId: Topic.ID  // 话题 id
    var content: String  // 评论内容
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }
}

extension Comment {
    var replays: Children<Comment, Replay> {
        return children(\Replay.commentId)
    }
}

extension Comment: Migration {}
extension Comment: PostgreSQLModel {}

