//
//  PhtotoComment.swift
//  App
//
//  Created by laijihua on 2018/10/28.
//

import Vapor
import FluentPostgreSQL
import Pagination

/// 图片评论
struct PhotoComment: Content {
    var id: Int?
    var userId: User.ID
    var userAvator: String?
    var userName: String
    var photoId: Photo.ID
    var content: String
    var likenum: Int // 点赞数
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }
    init(userId: User.ID, userName: String, userAvator: String? = nil, photoId: Photo.ID, content: String, likenum: Int = 0) {
        self.userId = userId
        self.userName = userName
        self.userAvator = userAvator
        self.photoId = photoId
        self.content = content
        self.likenum = likenum
    }
 }

extension PhotoComment: Paginatable {}
extension PhotoComment: Migration {}
extension PhotoComment: PostgreSQLModel {}
