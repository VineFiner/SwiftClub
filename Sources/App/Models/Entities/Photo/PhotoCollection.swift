//
//  PhotoCollection.swift
//  App
//
//  Created by laijihua on 2018/10/30.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Pagination

/// 图片收藏夹
struct PhotoCollection: Content {

    typealias Left = User
    typealias Right = Photo

    static var leftIDKey: LeftIDKey = \.userId
    static var rightIDKey: RightIDKey = \.photoId
    var id: Int?
    var userId: User.ID
    var photoId: Photo.ID
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(userId: Int, photoId: Int) {
        self.userId = userId
        self.photoId = photoId
    }
}

extension PhotoCollection: Migration {}
extension PhotoCollection: PostgreSQLPivot {}
