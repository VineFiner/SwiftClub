//
//  TopicCommentContainer.swift
//  App
//
//  Created by laijihua on 2018/10/22.
//
import Vapor
import FluentPostgreSQL

struct TopicCommentContainer: Content {
    var comment: Comment
    var replays: [Replay]

    init(comment: Comment, replays: [Replay]) {
        self.comment = comment
        self.replays = replays
    }
}
