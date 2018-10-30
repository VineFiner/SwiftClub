//
//  Photo.swift
//  App
//
//  Created by laijihua on 2018/10/28.
//

import Vapor
import FluentPostgreSQL
import Pagination

/// 图片模块图片
struct Photo: Content {
    var id: Int?
    var url: String
    var title: String  // 标题
    var intro: String? // 简介
    var tags: String // 关键字 , 分隔
    var cateId: PhotoCategory.ID // 分类 id
    var cateName: String
    var userId: User.ID
    var userName: String
    var userAvator: String?
    var ratio: Double   // 宽/高
    var commentNum: Int // 评论数
    var likeNum: Int  // 点赞数

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }
}

extension Photo {
    var comments: Children<Photo, PhotoComment> {
        return children(\PhotoComment.photoId)
    }

    var collectors: Siblings<Photo, User, PhotoCollection> {
        return siblings()
    }
}

extension Photo: Parameter {}
extension Photo: Paginatable {}
extension Photo: Migration {}
extension Photo: PostgreSQLModel {}


