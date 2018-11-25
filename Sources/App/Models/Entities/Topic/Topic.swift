//
//  Topic.swift
//  App
//
//  Created by laijihua on 2018/10/16.
//

/// 话题
import Vapor
import FluentPostgreSQL
import Pagination

final class Topic: Content {
    var id: Int?
    var title: String
    var subjectId: Subject.ID  // 主题
    var userId: User.ID // 发布人
    var content: String // markdown 内容

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(title: String, subjectId: Subject.ID, userId: User.ID, content: String) {
        self.title = title
        self.subjectId = subjectId
        self.userId = userId
        self.content = content
    }
}

extension Topic {
    // 作者
    var creator: Parent<Topic, User> {
        return parent(\.userId)
    }
    // 主题
    var subject: Parent<Topic, Subject> {
        return parent(\.subjectId)
    }
    // 评论
    var comments: Children<Topic, Comment> {
        return children(\Comment.id)
    }

}

extension Topic: Paginatable {}
extension Topic: Parameter {}

extension Topic: Migration {}
extension Topic: PostgreSQLModel {}

