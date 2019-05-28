//
//  Subject+Migrations.swift
//  App
//
//  Created by laijihua on 2019/4/10.
//

import Foundation
import FluentPostgreSQL

struct SubjectAddTopicNum: PostgreSQLMigration {


    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.update(Subject.self, on: conn, closure: { builder in
            builder.deleteField(for: \.topicNum)
        })
    }

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.update(Subject.self, on: conn, closure: { builder in
            builder.field(for: \.topicNum, type: PostgreSQLDataType.int, .default(0))
        })
    }
}

struct SubjectAddFocusNum: PostgreSQLMigration {
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.update(Subject.self, on: conn, closure: { builder in
            builder.deleteField(for: \.focusNum)
        })
    }

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.update(Subject.self, on: conn, closure: { builder in
            builder.field(for: \.focusNum, type: PostgreSQLDataType.int, .default(0))
        })
    }
}

