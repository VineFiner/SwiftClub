//
//  Reply.swift
//  App
//
//  Created by laijihua on 2018/10/22.
//

import Vapor
import FluentPostgreSQL

enum ReplayType: Int {
    case comment = 0
    case replay = 1
}
/// 评论回复表
struct Replay: Content {
    var id: Int?
    // A@B
    var userId: User.ID  // 回复用户 id  A
    var toUid: User.ID // 目标用户 id  B
    var commentId: Comment.ID // 评论 id
    var parentId: Replay.ID? // 父回复 id
    var replayType: Int // 回复类型
    
    var content: String
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }
}

extension Replay {

}

extension Replay: Migration {}
extension Replay: PostgreSQLModel {}
