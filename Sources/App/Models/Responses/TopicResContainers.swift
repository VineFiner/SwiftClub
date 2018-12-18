//
//  TopicResContainer.swift
//  App
//
//  Created by laijihua on 2018/12/17.
//

import Vapor

struct TopicCommentResContainer: Content {
    var id: Int?
    var userId: User.ID  // 评论人
    var userName: String?  // 评论人名字
    var userAvator: String? // 评论人图片
    var topicId: Topic.ID  // 话题 id
    var content: String  // 评论内容
    var createdAt: Date?

    init(comment: Comment, user: User) {
        self.id = comment.id
        self.userId = comment.userId
        self.userName = user.name
        self.userAvator = user.avator
        self.topicId = comment.targetId
        self.content = comment.content
        self.createdAt = comment.createdAt
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
    var replayType: Replay.ReplayType // 回复类型

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

struct TopicFullCommentResContainer: Content {
    var comment: TopicCommentResContainer
    var replays: [CommentReplayResContainer]
    init(comment: TopicCommentResContainer, replays: [CommentReplayResContainer]) {
        self.comment = comment
        self.replays = replays
    }
}

