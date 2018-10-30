//
//  PhotoCategory.swift
//  App
//
//  Created by laijihua on 2018/10/28.
//

import Vapor
import FluentPostgreSQL

/// 图片分类
struct PhotoCategory: Content {
    var id: Int?
    var name: String
    var icon: String?
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(name: String, icon: String? = nil) {
        self.name = name
        self.icon = icon
    }
}

extension PhotoCategory {
    var photos: Children<PhotoCategory, Photo> {
        return children(\Photo.cateId)
    }
}

extension PhotoCategory: Migration {}
extension PhotoCategory: PostgreSQLModel {}
