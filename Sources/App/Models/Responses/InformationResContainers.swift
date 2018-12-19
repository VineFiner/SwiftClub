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
