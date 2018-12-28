//
//  LibraryCategory.swift
//  App
//
//  Created by laijihua on 2018/12/23.
//


import Vapor
import FluentPostgreSQL

struct LibraryCategory: Content {
    var id: Int?
    var title: String

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }
}


extension LibraryCategory: Migration {}
extension LibraryCategory: PostgreSQLModel {}
