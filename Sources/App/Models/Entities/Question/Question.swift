//
//  Question.swift
//  App
//
//  Created by laijihua on 2018/12/18.
//

import Vapor
import FluentPostgreSQL

struct Question:Content {
    var id: Int?
    var creatorId: User.ID
    var title: String
    var content: String
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }
}

extension Question {
    var creator: Parent<Question, User> {
        return parent(\.creatorId)
    }
}

extension Question: Parameter {}

extension Question: PostgreSQLModel {}
extension Question: Migration {}
