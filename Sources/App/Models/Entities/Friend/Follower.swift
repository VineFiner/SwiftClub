//
//  Follower.swift
//  App
//
//  Created by laijihua on 2019/1/12.
//


import Vapor
import FluentPostgreSQL

struct Follower: Content {
    var id: Int?

    var userId: User.ID
    var followedId: User.ID

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }
}


extension Follower: Migration {}
extension Follower: PostgreSQLModel {}
