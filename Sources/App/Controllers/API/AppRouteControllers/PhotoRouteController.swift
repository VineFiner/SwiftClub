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
        tokenAuthGroup.get("comments", use: fetchMineComments)
        /// 获取我的收藏
        tokenAuthGroup.get("collectes", use: fetchMineCollects)
        /// 我的创作
        tokenAuthGroup.get("create", use: fetchMinePhotos)
        /// 添加
        tokenAuthGroup.post(PhotoAddContainer.self, at:"/", use: addPhoto)
        /// 搜索
        group.get("search", use: searchPhoto)

        /// 判断是否收藏过
        tokenAuthGroup.post(PhotoUserContainer.self, at:"isCollect", use: isCollect)

        /// 添加评论
        tokenAuthGroup.post(PhotoComment.self, at: "comment", use: addComment)
        /// 收藏
        tokenAuthGroup.post(PhotoUserContainer.self, at: Photo.parameter, "collecte", use: collectePhoto)
        /// 取消收藏
        tokenAuthGroup.post(PhotoUserContainer.self, at: Photo.parameter, "uncollect", use: unCollectePhoto)
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

        /// 不能使用 comment.save(on: request).always{}
        return try comment.save(on: request)
            .flatMap{ comment in
            return comment
                .photo
                .query(on: request)
                .first()
                .unwrap(or: ApiError.init(code: .modelNotExist))
                .flatMap(to: Void.self){ pho in
                    var tmp = pho
                    tmp.commentNum += 1
                    return tmp.update(on: request).map(to: Void.self, {_ in Void()})
                }
            }.makeJson(request: request)
    }

    func fetchPhotoCates(_ request: Request) throws -> Future<Response> {
        return try PhotoCategory.query(on: request).all().makeJson(on: request)
    }

    func collectePhoto(_ request: Request, container: PhotoUserContainer) throws -> Future<Response> {
        let _ = try request.authenticated(User.self)
        let userId = container.userId
        let photoId = container.photoId
        return PhotoCollection
            .query(on: request)
            .filter(\.photoId == photoId)
            .filter(\.userId == userId)
            .count()
            .flatMap { count in
                if count > 0 {
                    throw ApiError(code: ApiError.Code.custom)
                } else {
                    return try PhotoCollection(userId: userId, photoId: photoId).save(on: request).makeJson(on: request)
                }
            }
    }

    func unCollectePhoto(_ request: Request, container: PhotoUserContainer) throws -> Future<Response> {
        let _ = try request.authenticated(User.self)
        let userId = container.userId
        let photoId = container.photoId
        let likNumFuture = Photo
            .find(photoId, on: request)
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap { photo -> EventLoopFuture<Empty> in
                var tmp = photo
                tmp.likeNum -= 1
                return tmp.save(on: request).map(to: Empty.self, {_ in Empty()})
            }

        return try PhotoCollection
            .query(on: request)
            .filter(\.photoId == photoId)
            .filter(\.userId == userId)
            .delete()
            .and(likNumFuture)
            .map {_ in Void()}
            .makeJson(request: request)
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
        let _ = try request.authenticated(User.self)
        let userId = try request.query.get(Int.self, at: "userId")

        // TODO: 是否可以做分页
        return try User.find(userId, on: request)
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap{ return try $0.collectPhotos.query(on: request).paginate(for: request)  }
            .map{$0.response()}
            .makeJson(on: request)
    }

    func fetchMineComments(_ request: Request) throws -> Future<Response> {
        let _ = try request.authenticated(User.self)
        let userId = try request.query.get(Int.self, at: "userId")
        return try User.find(userId, on: request)
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap{ return try $0.photoComments.query(on: request).paginate(for: request) }
            .map{$0.response()}
            .makeJson(on: request)
    }

    func fetchMinePhotos(_ request: Request) throws -> Future<Response> {
        let _ = try request.authenticated(User.self)
        let userId = try request.query.get(Int.self, at: "userId")
        return try User
            .find(userId, on: request)
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap {return try $0.photos.query(on: request).paginate(for: request)}
            .map{$0.response()}
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

    func isCollect(_ request: Request, container: PhotoUserContainer) throws -> Future<Response> {
        let _ = try request.authenticated(User.self)
        return try PhotoCollection
            .query(on: request)
            .filter(\.photoId == container.photoId)
            .filter(\.userId == container.userId)
            .count()
            .makeJson(on: request)
    }
}
