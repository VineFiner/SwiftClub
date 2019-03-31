//
//  AccountReqContainers.swift
//  App
//
//  Created by laijihua on 2018/12/18.
//

import Vapor

struct UserWxAppOauthReqContainer: Content {
    let encryptedData: String // encryptedData
    let iv: String // iv
    let code: String
}

struct UserUpdateReqContainer: Content {
    var phone: String?
    var name: String?
    var avator: String?
    var info: String?
}

struct UserRegisterReqContainer: Content {
    let email: String
    let password: String
    let name: String
}

struct UserEmailReqContainer: Content {

    //MARK: Properties
    let email: String
}

struct RegisteCodeReqContainer: Content {
    var code: String
    var userId: User.ID
}

struct RefreshTokenReqContainer: Content {
    let refreshToken: RefreshToken.Token
    private enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

struct NewsPasswordReqContainer: Content {
    let email: String
    let password: String
    let newPassword: String
    let code: String
}

struct EmailLoginReqContainer: Content {
    let email: String
    let password: String
}








