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
    var icon: String? // 图标
    var topicNum: Int // 文章数量
    var focusNum: Int // 关注数

    var createdAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }

    init(name: String, remarks: String? = "", icon: String)  {
        self.name = name
        self.remarks = remarks
        self.icon = icon
        self.topicNum = 0
        self.focusNum = 0
    }
}

extension Subject: Migration {}
extension Subject: PostgreSQLModel {}
