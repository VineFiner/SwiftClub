//
//  InformationResContainers.swift
//  App
//
//  Created by laijihua on 2018/12/19.
//

import Vapor

struct InformationResContainer: Content {
    var id: Int?
    var title: String
    var desc: String
    var url: String
    var creatorId: User.ID
    var creatorAvator: String?
    var creatorName: String
    var createdAt: Date?
    init(info: Infomation, creator: User) {
        self.id = info.id
        self.title = info.title
        self.desc = info.desc
        self.url = info.url
        self.creatorId = info.creatorId
        self.creatorAvator = creator.avator
        self.creatorName = creator.name
        self.createdAt = info.createdAt
    }
}

struct InformationCommentResContainer: Content {
    var id: Int?
    var userId: User.ID  // 评论人
    var userName: String?  // 评论人名字
    var userAvator: String? // 评论人图片
    var topicId: Topic.ID  // 话题 id
    var content: String  // 评论内容
    var createdAt: Date?

    var commentCount: Int // 评论数
    var visitCount: Int // 浏览数

    init(comment: Comment, user: User, commentCount: Int = 0, visitCount: Int = 0) {
        self.id = comment.id
        self.userId = comment.userId
        self.userName = user.name
        self.userAvator = user.avator
        self.topicId = comment.targetId
        self.content = comment.content
        self.createdAt = comment.createdAt
        self.commentCount = commentCount
        self.visitCount = visitCount
    }
}

struct InformationFullCommentResContainer: Content {
    var comment: InformationCommentResContainer
    var replays: [CommentReplayResContainer]
    init(comment: InformationCommentResContainer, replays: [CommentReplayResContainer]) {
        self.comment = comment
        self.replays = replays
    }
}

