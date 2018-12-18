//
//  AccountResContainers.swift
//  App
//
//  Created by laijihua on 2018/12/18.
//

import Vapor

struct AuthenticationResContainer: Content {
    //MARK: Properties
    let accessToken: AccessToken.Token
    let expiresIn: TimeInterval
    let refreshToken: RefreshToken.Token

    //MARK: Initializers
    init(accessToken: AccessToken, refreshToken: RefreshToken) {
        self.accessToken = accessToken.token
        self.expiresIn = accessToken.expiryTime.timeIntervalSince1970 //Not honored, just an estimate
        self.refreshToken = refreshToken.token
    }

    //MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
    }
}


/// openId : 用户在当前小程序的唯一标识
struct WxAppUserInfoResContainer: Content {
    var openId: String
    var nickName: String
    var city: String
    var province: String
    var country: String
    var avatarUrl: String
    var unionId: String? // 如果开发者拥有多个移动应用、网站应用、和公众帐号（包括小程序），可通过unionid来区分用户的唯一性，因为只要是同一个微信开放平台帐号下的移动应用、网站应用和公众帐号（包括小程序），用户的unionid是唯一的。换句话说，同一用户，对同一个微信开放平台下的不同应用，unionId是相同的
    var watermark: WaterMark

    struct WaterMark: Content {
        var appid: String
        var timestamp: TimeInterval
    }
}

struct WxAppCodeResContainer: Content {
    var session_key: String
    var expires_in: TimeInterval
    var openid: String
}

