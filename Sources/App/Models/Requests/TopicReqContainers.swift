//
//  TopicReqContainers.swift
//  App
//
//  Created by laijihua on 2019/3/30.
//

import Vapor

struct TopicReqContainer: Content {
    var title: String
    var subjectId: Subject.ID
    var userId: User.ID
    var content: String
    var textType: Int // 1. markdown  2.html
    var tags:[Tag.ID] // tag 的 string
}

struct TagReqContainer: Content {
    var name: String
    var remarks: String?
}
