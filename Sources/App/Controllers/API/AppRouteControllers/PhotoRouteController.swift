//
//  PhotoController.swift
//  App
//
//  Created by laijihua on 2018/10/30.
//

import Vapor
import Fluent
import FluentPostgreSQL
import Pagination

final class PhotoRouteController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("api", "photos")
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])

        /// 获取列表
        group.get("/", use: listPhotos)
        /// 获取图片
        group.get(Photo.parameter, use: fetchPhoto)
        /// 获取评论
        group.get("comments", use: fetchComments)
        /// 获取分类
        group.get("cates", use: fetchPhotoCates)
        /// 添加评论
        tokenAuthGroup.post("comment", use: addComment)
        /// 收藏
        tokenAuthGroup.post("collection", use: collectionPhoto)
        /// 搜索
        group.get("search", use: searchPhoto)
    }
}

extension PhotoRouteController {
    func listPhotos(_ request: Request) throws -> Future<Response> {
        return try request.makeJson()
    }

    func fetchPhoto(_ request: Request) throws  -> Future<Response> {
        return try request.makeJson()
    }

    func fetchComments(_ request: Request) throws -> Future<Response> {
        return try request.makeJson()
    }

    func addComment(_ request: Request) throws -> Future<Response> {
        return try request.makeJson()
    }

    func collectionPhoto(_ request: Request) throws -> Future<Response> {
         return try request.makeJson()
    }

    func fetchPhotoCates(_ request: Request) throws -> Future<Response> {
        return try request.makeJson()
    }

    func searchPhoto(_ request: Request) throws -> Future<Response> {
        return try request.makeJson()
    }
}
