//
//  MiniTagRelation.swift
//  App
//
//  Created by laijihua on 2018/11/22.
//

import Vapor
import FluentPostgreSQL

/// 多对多
struct MiniTagPivot: PostgreSQLPivot {
    var id: Int?
    var miniId: Mini.ID
    var tagId: MiniTag.ID

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    typealias Left = Mini
    typealias Right = MiniTag

    static var leftIDKey: LeftIDKey = \.miniId
    static var rightIDKey: RightIDKey = \.tagId

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }
}

extension MiniTagPivot: Migration {}
