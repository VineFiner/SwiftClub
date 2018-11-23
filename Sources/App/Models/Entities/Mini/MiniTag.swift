//
//  MiniTag.swift
//  App
//
//  Created by laijihua on 2018/11/22.
//

import Vapor
import FluentPostgreSQL

struct MiniTag: Content {
    var id: Int?
    var name: String
    var icon: String?
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }
}

extension MiniTag: PostgreSQLModel {}
extension MiniTag: Migration {}
