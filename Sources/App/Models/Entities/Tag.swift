//
//  Tag.swift
//  App
//
//  Created by laijihua on 2018/12/18.
//

import Vapor
import FluentPostgreSQL

struct Tag:Content {
    var id: Int?
    var name: String
    var remarks: String? // 节点描述
    var topicCount: Int // 节点文章数
    var state: Int // 节点状态 1:open 0:close

    var createdAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }

    init(name: String, remarks: String? = nil, topicCount: Int = 0, state:Int = 1) {
        self.name = name
        self.remarks = remarks
        self.topicCount = topicCount
        self.state = state
    }
}

extension Tag: PostgreSQLModel {}
extension Tag: Migration {}
