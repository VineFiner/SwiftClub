//
//  TopicContainer.swift
//  App
//
//  Created by laijihua on 2018/10/23.
//

import Vapor
import FluentPostgreSQL

struct TopicContainer: Content {
    var user: User
    var topic: Topic
    init(topic: Topic, user: User) {
        self.topic = topic
        self.user = user
    }
}
