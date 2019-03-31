//
//  TopicResContainer.swift
//  App
//
//  Created by laijihua on 2018/12/17.
//

import Vapor

struct TopicResContainer: Content {
    var user: User
    var topic: Topic
    init(topic: Topic, user: User) {
        self.topic = topic
        self.user = user
    }
}

struct CommentReplayResContainer: Content {
    var id: Int?
    // A@B
    var userId: User.ID  // 回复用户 id  A
    var userName: String?
    var userAvator: String?
    var toUid: User.ID // 目标用户 id  B
    var toUname: String? // 目标用户名字
    var toUavator: String? // 目标用户头像
    var commentId: Comment.ID // 评论 id
    var parentId: Replay.ID? // 父回复 id
    var replayType: Int // 回复类型
    var content: String
    var createdAt: Date?

    init(replay: Replay, user: User, toUser: User) {
        self.id = replay.id
        self.userId = replay.userId
        self.userAvator = user.avator
        self.userName = user.name
        self.toUid = replay.toUid
        self.toUname = toUser.name
        self.toUavator = toUser.avator
        self.commentId = replay.commentId
        self.parentId = replay.parentId
        self.replayType = replay.replayType
        self.content = replay.content
        self.createdAt = replay.createdAt
    }
}


