//
//  Subject+AddIcon.swift
//  App
//
//  Created by laijihua on 2018/10/19.
//

import Vapor
import FluentPostgreSQL

struct SubjectAddIcon: Migration {
    typealias Database  = PostgreSQLDatabase

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Subject.self, on: conn, closure: { builder in
            builder.field(for: \.icon)
        })
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Subject.self, on: conn, closure: { builder in
            builder.deleteField(for: \.icon)
        })
    }
}
