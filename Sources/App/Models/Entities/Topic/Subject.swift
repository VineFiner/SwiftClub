//
//  Subject.swift
//  App
//
//  Created by laijihua on 2018/10/16.
//

import Vapor
import FluentPostgreSQL

/// 主题板块
struct Subject: Content {
    var id: Int?
    var name: String
    var remarks: String? // 描述
    var parentId: Subject.ID
    var path: String  // 便于查询
    var icon: String? // 图标

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(parentId: Subject.ID, name: String, remorks: String? = "", path: String, icon: String = "el-icon-menu") {
        self.name = name
        self.parentId = parentId
        self.path = path
        self.icon = icon
    }
}

extension Subject: Migration {}
extension Subject: PostgreSQLModel {}
