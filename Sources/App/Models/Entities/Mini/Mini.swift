//
//  Mini.swift
//  App
//
//  Created by laijihua on 2018/11/22.
//

import Vapor
import FluentPostgreSQL

struct Mini: Content {
    var id: Int?
    var developerMessage: String?
    var description: String
    var releaseStatus: String
    var reputaion: Double
    var createdBy: User.ID
    var name: String
    var visitAmount: Int
    var recommendationReason: String?
    var isRecommended: Bool
    var recommendedAt: Date?
    var screenshot: [String]
    var rating:[Int] // 有5个值，每个值代表每个等级的星星的个数
    var overallRating: Int // 综合评分
    var qrcode: String // 小程序二维码
    var label: String?

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }
}

extension Mini: PostgreSQLModel {}
extension Mini: Migration {}
