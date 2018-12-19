//
//  TopicTag.swift
//  App
//
//  Created by laijihua on 2018/12/18.
//

import Vapor
import FluentPostgreSQL

struct TopicTag: PostgreSQLPivot {
    var id: Int?
    var tagId: Tag.ID
    var topicId: Topic.ID

    typealias Left = Topic
    typealias Right = Tag

    static var leftIDKey: LeftIDKey = \.topicId
    static var rightIDKey: RightIDKey = \.tagId

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }
}

extension TopicTag: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.topicId, to: \Topic.id)
            builder.reference(from: \.tagId, to: \Tag.id)
        }
    }
}
