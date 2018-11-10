//
//  PhotoAddContainer.swift
//  App
//
//  Created by laijihua on 2018/11/3.
//

import Vapor
import FluentPostgreSQL

struct PhotoAddContainer: Content {
    var url: String
    var title: String // 标题
    var intro: String? // 简介
    var tags: String? // 关键字 , 分隔
    var cateId: PhotoCategory.ID // 分类 id
    var userId: User.ID
    var ratio: Double   // 宽/高
}

struct PhotoUserContainer: Content {
    var userId: Int
    var photoId: Int
}
