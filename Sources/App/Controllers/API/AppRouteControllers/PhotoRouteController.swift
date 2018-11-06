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

        /// 获取七牛token
        group.get("token", use: fetchQiniuToken)
        /// 获取列表
        group.get("/", use: listPhotos)
        /// 获取图片
        group.get(Photo.parameter, use: fetchPhoto)
        /// 获取评论
        group.get(Photo.parameter, "comments", use: fetchComments)
        /// 获取分类
        group.get("cates", use: fetchPhotoCates)
        /// 获取分类下的图片
        group.get("cate", "photos", use: fetchCatePhotos)

        /// 获取我的评论
        group.get("comments", use: fetchMineComments)
        /// 获取我的收藏
        group.get("collectes", use: fetchMineCollects)
        /// 我的创作
        group.get("create", use: fetchMinePhotos)
        /// 添加
        group.post(PhotoAddContainer.self, at:"/", use: addPhoto)
        /// 搜索
        group.get("search", use: searchPhoto)
        /// 添加评论
        tokenAuthGroup.post(PhotoComment.self, at: "comment", use: addComment)
        /// 收藏
        tokenAuthGroup.post(Photo.parameter, "collecte", use: collectePhoto)
        /// 取消收藏
        tokenAuthGroup.post(Photo.parameter, "uncollect", use: unCollectePhoto)
    }
}

extension PhotoRouteController {



    /// 获取七牛 token
    func fetchQiniuToken(_ request: Request) throws -> Future<Response> {
        let token = try QiniuService.token()
        return try request.makeJson(token)
    }

    /// 添加图片接口
    func addPhoto(_ reqeust: Request, container: PhotoAddContainer) throws -> Future<Response> {
        let _ = try reqeust.authenticated(User.self)
        let result = flatMap(to: Photo.self, User.find(container.userId, on: reqeust), PhotoCategory.find(container.cateId, on: reqeust)) { (user, category) in
            guard let user = user , let cate = category else {
                throw ApiError(code: ApiError.Code.modelNotExist)
            }
            let photo = Photo(user: user, cate: cate, container: container)
            return photo.save(on: reqeust)
        }
        return try result.makeJson(on: reqeust)
    }

    /// 获取图片列表
    func listPhotos(_ request: Request) throws -> Future<Response> {

        if let type = try request.query.get(Int?.self, at: "type") {
            if type == 1 { // hot
                return try Photo
                    .query(on: request)
                    .paginate(for: request, [PostgreSQLOrderBy.orderBy(PostgreSQLExpression.column(\Photo.likeNum), PostgreSQLDirection.descending)])
                    .map { $0.response()}
                    .makeJson(on: request)
            } else { // newer
                return try Photo
                    .query(on: request)
                    .paginate(for: request)
                    .map { $0.response()}
                    .makeJson(on: request)
            }
        } else {
            return try Photo
                .query(on: request)
                .paginate(for: request)
                .map { $0.response()}
                .makeJson(on: request)
        }
    }

    /// 获取图片详情
    func fetchPhoto(_ request: Request) throws  -> Future<Response> {
        return try request.parameters.next(Photo.self).makeJson(on: request)
    }

    /// 获取图片评论
    func fetchComments(_ request: Request) throws -> Future<Response> {
        return try request
            .parameters
            .next(Photo.self)
            .flatMap(to: Page<PhotoComment>.self, { photo in
                return try photo
                    .comments
                    .query(on: request)
                    .paginate(for: request)
            })
            .map{ $0.response()}
            .makeJson(on: request)
    }

    /// 添加评论
    func addComment(_ request: Request, comment: PhotoComment) throws -> Future<Response> {
        let _ = try request.authenticated(User.self)
        return try comment.save(on: request).makeJson(on: request).always {
            _ = Photo.query(on: request)
                .first()
                .unwrap(or: ApiError(code: .modelNotExist))
                .flatMap (to: Void.self){ photo in
                    var tmpPhoto = photo
                    tmpPhoto.commentNum += 1
                    return tmpPhoto.save(on: request).map(to: Void.self, {_ in })
                }
        }
    }

    func fetchPhotoCates(_ request: Request) throws -> Future<Response> {
        return try PhotoCategory.query(on: request).all().makeJson(on: request)
    }

    func collectePhoto(_ request: Request) throws -> Future<Response> {
         return try request.makeJson()
    }

    func unCollectePhoto(_ request: Request) throws -> Future<Response> {
        return try request.makeJson()
    }

    func searchPhoto(_ request: Request) throws -> Future<Response> {
        let searchKey = try request.query.get(String.self, at: "title")
        return try Photo.query(on: request)
            .filter(\Photo.title == searchKey)
            .paginate(for: request)
            .map { $0.response()}
            .makeJson(on: request)
    }

    func fetchMineCollects(_ request: Request) throws -> Future<Response> {
        return try request.makeJson()
    }

    func fetchMineComments(_ request: Request) throws -> Future<Response> {
        return try request.makeJson()
    }

    func fetchMinePhotos(_ request: Request) throws -> Future<Response> {
        let _ = try request.authenticated(User.self)
        let userId = try request.query.get(Int.self, at: "userId")
        return try User
            .find(userId, on: request)
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap {return try $0.photos.query(on: request).all()}
            .makeJson(on: request)
    }

    func fetchCatePhotos(_ request: Request) throws -> Future<Response> {
        let cateId = try request.query.get(Int.self, at: "cateId")
        return try PhotoCategory
            .find(cateId, on: request)
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap {
                return try $0.photos.query(on: request).paginate(for: request)
            }.map{$0.response()}
            .makeJson(on: request)
    }
}
