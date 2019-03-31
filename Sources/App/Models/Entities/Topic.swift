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

struct Topic: Content {
    var id: Int?
    var title: String  // 标题
    var subjectId: Subject.ID  // 主题
    var userId: User.ID // 发布人

    var content: String // 内容
    var textType: Int // 1. markdown  2.html

    var weight: Int // 帖子权重
    var popular: Bool // 是否是精华帖
    var commentCount: Int // 评论数
    var loveCount: Int // 点赞数
    var collectCount: Int // 收藏数
    var browserCount: Int // 浏览数

    var replayUserId: User.ID? // 最后回复人
    var replayedAt: Date? // 最后回复时间

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(title: String, subjectId: Subject.ID, userId: User.ID, content: String, textType: TextType) {
        self.title = title
        self.subjectId = subjectId
        self.userId = userId
        self.content = content
        self.textType = textType.rawValue
        self.weight = 1
        self.popular = false
        self.commentCount = 0
        self.loveCount = 0
        self.collectCount = 0
        self.browserCount = 0
    }
}

extension Topic {
    enum TextType: Int {
        case markdown = 1
        case html = 2

        init(type: Int) {
            if type == 1 {self = .markdown}
            else {self = .html}
        }
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

    // tags
    var tags: Siblings<Topic, Tag, TopicTag> {
        return siblings()
    }

}

extension Topic: Paginatable {}
extension Topic: Parameter {}

extension Topic: Migration {}
extension Topic: PostgreSQLModel {}

