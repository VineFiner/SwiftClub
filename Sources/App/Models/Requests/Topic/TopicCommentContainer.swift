//
//  TopicCommentContainer.swift
//  App
//
//  Created by laijihua on 2018/10/22.
//
import Vapor
import FluentPostgreSQL

struct TopicCommentContainer: Content {
    var comment: TopicCommentResContainer
    var replays: [CommentReplayResContainer]

    init(comment: TopicCommentResContainer, replays: [CommentReplayResContainer]) {
        self.comment = comment
        self.replays = replays
    }
}
