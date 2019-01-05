//
//  QuestionCommentReqContainer.swift
//  App
//
//  Created by laijihua on 2019/1/5.
//

import Vapor

struct QuestionCommentReqContainer: Content {
    var questionId: Question.ID  //
    var userId: User.ID  // 评论人
    var content: String  // 评论内容
}
