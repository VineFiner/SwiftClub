//
//  TopicReqContainers.swift
//  App
//
//  Created by laijihua on 2018/12/18.
//

import Vapor
import FluentPostgreSQL

struct TopicResContainer: Content {
    var user: User
    var topic: Topic
    init(topic: Topic, user: User) {
        self.topic = topic
        self.user = user
    }
}

struct TopicCommentReqContainer: Content {
    var topicId: Topic.ID  //
    var userId: User.ID  // 评论人
    var content: String  // 评论内容
}
