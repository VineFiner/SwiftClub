//
//  Comment.swift
//  App
//
//  Created by laijihua on 2018/10/22.
//

import Vapor
import FluentPostgreSQL

enum CommentType: Int, PostgreSQLEnum, PostgreSQLMigration {
    case topic = 0
    case photo = 1
    case information = 2
    case question = 3
}

/// 评论表， 设计为二级评论表
struct Comment: Content {
    var id: Int?
    var targetType: CommentType  // 评论类型： topic | photo
    var targetId: Int  // 评论目标的 id
    var userId: User.ID  // 评论人
    var content: String  // 评论内容
    var likeNum: Int  // 点赞数

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(targetType: CommentType = .topic, targetId: Int, userId: User.ID, content: String) {
        self.targetType = targetType
        self.targetId = targetId
        self.userId = userId
        self.content = content
        self.likeNum = 0
    }
}


extension Comment {
    var replays: Children<Comment, Replay> {
        return children(\Replay.commentId)
    }
}

extension Comment: Migration {}
extension Comment: PostgreSQLModel {}

