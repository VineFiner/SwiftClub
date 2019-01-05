//
//  QuestionResContainer.swift
//  App
//
//  Created by laijihua on 2018/12/23.
//

import Foundation
import Vapor

struct QuestionResContainer: Content {
    var creator: User
    var question: Question
    var commentCount: Int

    init(user: User, question: Question, commentCount: Int) {
        self.creator = user
        self.question = question
        self.commentCount = commentCount
    }
}
