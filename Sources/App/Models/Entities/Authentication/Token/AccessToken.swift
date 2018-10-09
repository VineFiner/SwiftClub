//
//  AccessToken.swift
//  App
//
//  Created by laijihua on 2018/6/15.
//

import Vapor
import FluentPostgreSQL
import Crypto
import Authentication


struct AccessToken: Content {
    struct Const {
        static let expirationInterval: TimeInterval = 3600
    }
    typealias Token = String
    var id: Int?
    private(set) var token: Token
    private(set) var userId: Int
    let expiryTime: Date

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(userId: Int) throws {
        self.token = try CryptoRandom().generateData(count: 32).base64URLEncodedString()
        self.userId = userId
        self.expiryTime = Date().addingTimeInterval(Const.expirationInterval)
    }
}

extension AccessToken: PostgreSQLModel {}
extension AccessToken: Migration {}


extension AccessToken: BearerAuthenticatable {
    static var tokenKey: WritableKeyPath<AccessToken, String> = \.token
    static func authenticate(using bearer: BearerAuthorization, on connection: DatabaseConnectable) -> Future<AccessToken?> {
        return Future.flatMap(on: connection) {
            return AccessToken.query(on: connection)
                .filter(tokenKey == bearer.token)
                .first()
                .map{ token in
                    guard let token = token, token.expiryTime > Date() else {
                        return nil
                    }
                    return token
            }
        }
    }
}

extension AccessToken: Token {
    typealias UserType = User
    static var userIDKey: WritableKeyPath<AccessToken, Int> = \.userId
}

