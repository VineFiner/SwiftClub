//
//  Library.swift
//  App
//
//  Created by laijihua on 2018/12/23.
//

/// 开源库
import Vapor
import FluentPostgreSQL

struct Library: Content {
    var id: Int?
    var title: String
    var url: String
    var desc: String
    var content: String
    var categoryId: LibraryCategory.ID

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }
}


extension Library: Migration {}
extension Library: PostgreSQLModel {}




