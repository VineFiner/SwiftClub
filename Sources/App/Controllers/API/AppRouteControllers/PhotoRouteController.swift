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
                    .range(request.pageRange)
                    .sort(\Photo.likeNum)
                    .join(\PhotoCategory.id, to: \Photo.cateId)
                    .join(\User.id, to: \Photo.userId)
                    .alsoDecode(PhotoCategory.self)
                    .alsoDecode(User.self)
                    .all()
                    .map (to:[PhotoResContainer].self, { tuples in
                        let data = tuples.map { tuple in
                            return PhotoResContainer(user: tuple.1, category: tuple.0.1, photo: tuple.0.0)
                        }
                        return data
                    }).flatMap{ results in
                        return Photo.query(on: request).count().map(to: Paginated<PhotoResContainer>.self) { count in
                            return request.paginated(data: results, total: count)
                        }
                    }.makeJson(on: request)
            } else { // newer
                return try Photo
                    .query(on: request)
                    .range(request.pageRange)
                    .sort(\Photo.createdAt, PostgreSQLDirection.descending)
                    .join(\PhotoCategory.id, to: \Photo.cateId)
                    .join(\User.id, to: \Photo.userId)
                    .alsoDecode(PhotoCategory.self)
                    .alsoDecode(User.self)
                    .all()
                    .map (to:[PhotoResContainer].self, { tuples in
                        let data = tuples.map { tuple in
                            return PhotoResContainer(user: tuple.1, category: tuple.0.1, photo: tuple.0.0)
                        }
                        return data
                    }).flatMap{ results in
                        return Photo.query(on: request).count().map(to: Paginated<PhotoResContainer>.self) { count in
                            return request.paginated(data: results, total: count)
                        }
                    }.makeJson(on: request)
            }
        } else {
            return try Photo
                .query(on: request)
                .range(request.pageRange)
                .join(\PhotoCategory.id, to: \Photo.cateId)
                .join(\User.id, to: \Photo.userId)
                .alsoDecode(PhotoCategory.self)
                .alsoDecode(User.self)
                .all()
                .map (to:[PhotoResContainer].self, { tuples in
                    let data = tuples.map { tuple in
                        return PhotoResContainer(user: tuple.1, category: tuple.0.1, photo: tuple.0.0)
                    }
                    return data
                }).flatMap{ results in
                    return Photo.query(on: request).count().map(to: Paginated<PhotoResContainer>.self) { count in
                        return request.paginated(data: results, total: count)
                    }
                }.makeJson(on: request)
        }
    }

    /// 获取图片详情
    func fetchPhoto(_ request: Request) throws  -> Future<Response> {
        return try request.parameters.next(Photo.self).flatMap { photo -> EventLoopFuture<PhotoResContainer> in
            let catFuture = PhotoCategory.find(photo.cateId, on: request).unwrap(or: ApiError(code: .modelNotExist))
            let userFuture = User.find(photo.userId, on: request).unwrap(or: ApiError(code: .modelNotExist))

            let result = map(catFuture, userFuture, { (cat, user) in
                return PhotoResContainer(user: user, category: cat, photo: photo)
            })
            return result
        }.makeJson(on: request)
    }

    /// 获取图片评论
    func fetchComments(_ request: Request) throws -> Future<Response> {
        return try request
            .parameters
            .next(Photo.self)
            .flatMap{ photo in
                return try photo
                    .comments
                    .query(on: request)
                    .range(request.pageRange)
                    .join(\User.id, to: \PhotoComment.userId)
                    .alsoDecode(User.self)
                    .all()
                    .map (to: [PhotoCommentResContainer].self, {tuples in
                        return tuples.map { tuple in
                            return PhotoCommentResContainer(comment: tuple.0, commentUser: tuple.1)
                        }
                    }).flatMap { results in
                        return try photo.comments.query(on: request).count().map(to: Paginated<PhotoCommentResContainer>.self) { count in
                            return request.paginated(data: results, total: count)
                        }
                    }.makeJson(on: request)
            }
    }

    /// 添加评论
    func addComment(_ request: Request, comment: PhotoComment) throws -> Future<Response> {
        let _ = try request.authenticated(User.self)
        return try comment
            .save(on: request)
            .flatMap{ comment in
                return comment
                    .photo
                    .query(on: request)
                    .first()
                    .unwrap(or: ApiError(code: .modelNotExist))
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
            .range(request.pageRange)  // # TODO: 太高频率，需要重构
            .join(\PhotoCategory.id, to: \Photo.cateId)
            .join(\User.id, to: \Photo.userId)
            .alsoDecode(PhotoCategory.self)
            .alsoDecode(User.self)
            .all()
            .map (to:[PhotoResContainer].self, { tuples in
                let data = tuples.map { tuple in
                    return PhotoResContainer(user: tuple.1, category: tuple.0.1, photo: tuple.0.0)
                }
                return data
            }).flatMap{ results in
                return Photo.query(on: request).count().map(to: Paginated<PhotoResContainer>.self) { count in
                    return request.paginated(data: results, total: count)
                }
            }.makeJson(on: request)
    }

    func fetchMineCollects(_ request: Request) throws -> Future<Response> {
        let _ = try request.authenticated(User.self)
        let userId = try request.query.get(Int.self, at: "userId")
        return User.find(userId, on: request)
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap { user in
                return try user
                    .collectPhotos
                    .query(on: request)
                    .range(request.pageRange)  // TODO: 这段高频代码需要重构起来
                    .join(\PhotoCategory.id, to: \Photo.cateId)
                    .join(\User.id, to: \Photo.userId)
                    .alsoDecode(PhotoCategory.self)
                    .alsoDecode(User.self)
                    .all()
                    .map (to:[PhotoResContainer].self, { tuples in
                        let data = tuples.map { tuple in
                            return PhotoResContainer(user: tuple.1, category: tuple.0.1, photo: tuple.0.0)
                        }
                        return data
                    }).flatMap{ results in
                        return Photo.query(on: request).count().map(to: Paginated<PhotoResContainer>.self) { count in
                            return request.paginated(data: results, total: count)
                        }
                    }.makeJson(on: request)
            }
    }

    func fetchMineComments(_ request: Request) throws -> Future<Response> {
        let _ = try request.authenticated(User.self)
        let userId = try request.query.get(Int.self, at: "userId")
        return User.find(userId, on: request)
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap{ user in
                return try user.photoComments
                    .query(on: request)
                    .range(request.pageRange)
                    .join(\User.id, to: \PhotoComment.userId)
                    .alsoDecode(User.self)
                    .all()
                    .map (to: [PhotoCommentResContainer].self, {tuples in
                        return tuples.map { tuple in
                            return PhotoCommentResContainer(comment: tuple.0, commentUser: tuple.1)
                        }
                    }).flatMap { results in
                        return try user.photoComments.query(on: request).count().map(to: Paginated<PhotoCommentResContainer>.self) { count in
                            return request.paginated(data: results, total: count)
                        }
                    }.makeJson(on: request)
            }
    }

    func fetchMinePhotos(_ request: Request) throws -> Future<Response> {
        let _ = try request.authenticated(User.self)
        let userId = try request.query.get(Int.self, at: "userId")
        return  User
            .find(userId, on: request)
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap { return
                try $0.photos
                    .query(on: request)
                    .range(request.pageRange)  // TODO: 这段高频代码需要重构起来
                    .join(\PhotoCategory.id, to: \Photo.cateId)
                    .join(\User.id, to: \Photo.userId)
                    .alsoDecode(PhotoCategory.self)
                    .alsoDecode(User.self)
                    .all()
                    .map (to:[PhotoResContainer].self, { tuples in
                        let data = tuples.map { tuple in
                            return PhotoResContainer(user: tuple.1, category: tuple.0.1, photo: tuple.0.0)
                        }
                        return data
                    }).flatMap{ results in
                        return Photo.query(on: request).count().map(to: Paginated<PhotoResContainer>.self) { count in
                            return request.paginated(data: results, total: count)
                        }
                    }.makeJson(on: request)
        }
    }

    func fetchCatePhotos(_ request: Request) throws -> Future<Response> {
        let cateId = try request.query.get(Int.self, at: "cateId")
        return PhotoCategory
            .find(cateId, on: request)
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap {
                return try $0.photos
                    .query(on: request)
                    .range(request.pageRange)  // TODO: 这段高频代码需要重构起来
                    .join(\PhotoCategory.id, to: \Photo.cateId)
                    .join(\User.id, to: \Photo.userId)
                    .alsoDecode(PhotoCategory.self)
                    .alsoDecode(User.self)
                    .all()
                    .map (to:[PhotoResContainer].self, { tuples in
                        let data = tuples.map { tuple in
                            return PhotoResContainer(user: tuple.1, category: tuple.0.1, photo: tuple.0.0)
                        }
                        return data
                    }).flatMap{ results in
                        return Photo.query(on: request).count().map(to: Paginated<PhotoResContainer>.self) { count in
                            return request.paginated(data: results, total: count)
                        }
                    }.makeJson(on: request)
        }
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
