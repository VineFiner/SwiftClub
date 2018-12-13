//
//  TopicResContainer.swift
//  App
//
//  Created by laijihua on 2018/12/13.
//

import Vapor

struct PhotoCommentResContainer: Content {
    var id: Int?
    var userId: User.ID
    var userAvator: String?
    var userName: String
    var photoId: Photo.ID
    var content: String
    var likenum: Int // 点赞数
    var createdAt: Date?

    init(comment: PhotoComment, commentUser: User) {
        self.id = comment.id
        self.userId = comment.userId
        self.userAvator = commentUser.avator
        self.userName = commentUser.name
        self.photoId = comment.photoId
        self.likenum = comment.likenum
        self.content = comment.content
        self.createdAt = comment.createdAt
    }
}

struct PhotoResContainer: Content {
    var id: Int?
    var url: String
    var title: String  // 标题
    var intro: String? // 简介
    var tags: String // 关键字 , 分隔

    var cateId: PhotoCategory.ID // 分类 id
    var cateName: String

    var ratio: Double   // 宽/高
    var commentNum: Int // 评论数
    var likeNum: Int  // 点赞数

    var userId: User.ID
    var userName: String
    var userAvator: String?

    var createdAt: Date?

    init(user: User, category: PhotoCategory, photo: Photo) {
        self.id = photo.id
        self.url = photo.url
        self.title = photo.title
        self.intro = photo.intro
        self.tags = photo.tags
        self.cateId = photo.cateId
        self.cateName = category.name
        self.ratio = photo.ratio
        self.commentNum = photo.commentNum
        self.likeNum = photo.likeNum
        self.userId = photo.userId
        self.userAvator = user.avator
        self.userName = user.name
        self.createdAt = photo.createdAt
    }
}
