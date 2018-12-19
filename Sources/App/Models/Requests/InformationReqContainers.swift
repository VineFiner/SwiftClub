//
//  InformationReqContainers.swift
//  App
//
//  Created by laijihua on 2018/12/19.
//

import Vapor

struct InformationCommentReqContainer: Content {
    var informationId: Infomation.ID  //
    var userId: User.ID  // 评论人
    var content: String  // 评论内容
}
