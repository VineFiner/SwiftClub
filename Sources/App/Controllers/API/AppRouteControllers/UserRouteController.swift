//
//  UserRouteController.swift
//  App
//
//  Created by laijihua on 2018/6/16.
//

import Vapor
import Crypto
import FluentPostgreSQL
import CNIOOpenSSL
import Pagination

final class UserRouteController: RouteCollection {
    private let authService = AuthenticationService()
    private let notifyService = NotifyService()

    func boot(router: Router) throws {
        let group = router.grouped("users")
        group.post(EmailLoginReqContainer.self, at: "login", use: loginUserHandler)
        group.post(UserRegisterReqContainer.self, at: "register", use: registerUserHandler)
        /// 修改密码 
        group.post(NewsPasswordReqContainer.self, at:"newPassword", use: newPassword)

        /// 发送修改密码验证码
        group.post(UserEmailReqContainer.self, at:"changePwdCode", use: sendPwdCode)

        /// 激活校验码
        group.get("activate", use: activeRegisteEmailCode)

        // 微信小程序
        // /oauth/token 通过小程序提供的验证信息获取服务器自己的 token
        group.post(UserWxAppOauthReqContainer.self, at: "/oauth/token", use: wxappOauthToken)

        //// 用户接口
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()

        let userGroup = router.grouped("api", "user")
        let tokenAuthGroup = userGroup.grouped([tokenAuthMiddleware, guardAuthMiddleware])

        /// 用户信息
        userGroup.get(User.parameter, "info", use: fetchUserInfo)
        /// 用户文章
        userGroup.get(User.parameter, "topics", use: fetchUserTopics)
        /// 用户问答
        
        /// 获取用户关注的内容
        tokenAuthGroup.get("focus", use: fetchUserFocus)
        tokenAuthGroup.get("focus", "pull", use: pullUserFocus)
    }
}


extension UserRouteController {

    func pullUserFocus(request: Request) throws -> Future<Response> {
        let _ = try request.authenticated(User.self)
        let userId = try request.query.get(Int.self, at: "userId")
        return try self.notifyService.pullRemind(userId: userId, on: request).makeJson(request:request)
    }

    /// 获取用户关注对象产生的事件列表, 每次用户进入页面需要进行 pull
    func fetchUserFocus(request: Request) throws -> Future<Response> {
        let _ = try request.authenticated(User.self)
        let userId = try request.query.get(Int.self, at: "userId")
        return try self.notifyService.getUserNotify(userId: userId, on: request)
    }


    func fetchUserTopics(request: Request) throws -> Future<Response> {
        return try request.parameters.next(User.self).flatMap { user in
            return try Topic
                .query(on: request)
                .filter(\Topic.userId == user.requireID())
                .sort(\Topic.createdAt, .descending)
                .range(request.pageRange) // 获取分页数据
                .join(\User.id, to: \Topic.userId)
                .alsoDecode(User.self)
                .all()
                .map { tuples in
                    return tuples.map { tuple in  return TopicResContainer(topic: tuple.0, user: tuple.1)}
                }.flatMap{ results in
                    return try Topic.query(on: request).filter(\Topic.userId == user.requireID()).count().map(to: Paginated<TopicResContainer>.self) { count in
                        return request.paginated(data: results, total: count)
                    }
                }
                .makeJson(on:request)
        }
    }

    /// 获取用户信息
    func fetchUserInfo(request: Request) throws -> Future<Response> {
        return try request.parameters.next(User.self).makeJson(on: request)
    }
}

//MARK: Helper
private extension UserRouteController {
    /// 小程序调用wx.login() 获取 临时登录凭证code ，并回传到开发者服务器。
    // 开发者服务器以code换取用户唯一标识openid 和 会话密钥session_key。
    func wxappOauthToken(_ request: Request, container: UserWxAppOauthReqContainer) throws -> Future<Response> {

        let appId = "wx295f34d030798e48"
        let secret = "39a549d066a34c56c8f1d34d606e3a95"
        let url = "https://api.weixin.qq.com/sns/jscode2session?appid=\(appId)&secret=\(secret)&js_code=\(container.code)&grant_type=authorization_code"
        return try request
            .make(Client.self)
            .get(url)
            .flatMap { response in
            guard let res = response.http.body.data else {
                throw ApiError(code:.custom)
            }
            let resContainer = try JSONDecoder().decode(WxAppCodeResContainer.self,from: res)
            let sessionKey = try resContainer.session_key.base64decode()
            let encryptedData = try container.encryptedData.base64decode()
            let iv = try container.iv.base64decode()

            guard let cbc = EVP_aes_128_cbc(), let evp_aes_128_cbc = OpaquePointer(UnsafePointer(cbc)) else {
                throw ApiError(code:.custom)
            }
            let cipherAlgorithm = CipherAlgorithm(c: evp_aes_128_cbc)
            let shiper = Cipher(algorithm: cipherAlgorithm)

            let decrypted = try shiper.decrypt(encryptedData, key: sessionKey, iv: iv)
            let data = try JSONDecoder().decode(WxAppUserInfoResContainer.self, from: decrypted)

            if data.watermark.appid == appId {
                /// 通过 resContainer.session_key 和 data.openid
                ///
                return UserAuth
                    .query(on: request)
                    .filter(\.identityType == UserAuth.AuthType.wxapp.rawValue)
                    .filter(\.identifier == data.openId)
                    .first()
                    .flatMap { userauth in
                        if let userAuth = userauth { // 该用户已授权过， 更新
                            var userAu = userAuth
                            let digest = try request.make(BCryptDigest.self)
                            userAu.credential = try digest.hash(resContainer.session_key)
                            return userAu
                                .update(on: request)
                                .flatMap { _ in
                                return try self.authService.authenticationContainer(for: userAuth.userId, on: request)
                            }
                        } else { // 注册
                            var userAuth = UserAuth(userId: nil, identityType: .wxapp, identifier: data.openId, credential: resContainer.session_key)
                            let newUser = User(name: data.nickName,
                                               avator: data.avatarUrl)
                            return newUser
                                .create(on: request)
                                .flatMap { user in
                                    userAuth.userId = try user.requireID()
                                    return try userAuth
                                        .userAuth(with: request.make(BCryptDigest.self))
                                        .create(on: request)
                                        .flatMap { _ in
                                            return try self.authService.authenticationContainer(for: user.requireID(), on: request)
                                    }
                            }
                        }
                }
            } else {
                throw ApiError(code: .custom)
            }
        }
    }

    // 激活注册校验码
    func activeRegisteEmailCode(_ request: Request) throws -> Future<Response> {
        // 获取到参数
        let filters = try request.query.decode(RegisteCodeReqContainer.self)
        return ActiveCode
            .query(on: request)
            .filter(\ActiveCode.codeType == ActiveCode.CodeType.activeAccount.rawValue)
            .filter(\ActiveCode.userId == filters.userId)
            .filter(\ActiveCode.code == filters.code)
            .first()
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap { code in
                code.state = true
                return try code
                    .save(on: request)
                    .map(to: Void.self, {_ in return })
                    .makeJson(request: request)
            }
    }


    /// 发送修改密码的验证码
    func sendPwdCode(_ request: Request, container: UserEmailReqContainer) throws -> Future<Response> {
        return UserAuth
            .query(on: request)
            .filter(\.identityType == UserAuth.AuthType.email.rawValue)
            .filter(\.identifier == container.email)
            .first()
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap { existAuth in
                let codeStr: String = try String.random(length: 4)
                let activeCode = ActiveCode(userId: existAuth.userId, code: codeStr, type: .changePwd)
                return try activeCode
                    .create(on: request)
                    .flatMap { acode in
                        let content = EmailSender.Content.changePwd(emailTo: container.email, code: codeStr)
                        return try self.sendMail(request: request, content: content)
                    }.makeJson(request: request)
            }

    }

    func loginUserHandler(_ request: Request, container: EmailLoginReqContainer) throws -> Future<Response> {
        return UserAuth
            .query(on: request)
            .filter(\UserAuth.identityType == UserAuth.AuthType.email.rawValue)
            .filter(\UserAuth.identifier == container.email)
            .first()
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap { existingAuth in
                let digest = try request.make(BCryptDigest.self)
                guard try digest.verify(container.password, created: existingAuth.credential) else {
                    throw ApiError(code: .authFail)
                }
                return try self.authService.authenticationContainer(for: existingAuth.userId, on: request)
            }
    }

    // TODO: send email has some error , wait 
    func newPassword(_ request: Request, container: NewsPasswordReqContainer) throws -> Future<Response> {

        return UserAuth
            .query(on: request)
            .filter(\UserAuth.identityType == UserAuth.AuthType.email.rawValue)
            .filter(\UserAuth.identifier == container.email)
            .first()
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap{ userAuth in
                return userAuth
                    .user
                    .query(on: request)
                    .first()
                    .unwrap(or: ApiError(code: .modelNotExist))
                    .flatMap { user in
                        return try user
                            .codes
                            .query(on: request)
                            .filter(\ActiveCode.codeType == ActiveCode.CodeType.changePwd.rawValue)
                            .filter(\ActiveCode.code == container.code)
                            .first()
                            .flatMap { code in
                                // 只有激活的用户才可以修改密码
                                guard let code = code, code.state else {
                                    throw ApiError(code: .codeFail)
                                }
                                var tmpUserAuth = userAuth
                                tmpUserAuth.credential = container.password
                                return try tmpUserAuth
                                    .userAuth(with: request.make(BCryptDigest.self))
                                    .save(on: request)
                                    .map(to: Void.self, {_ in return })
                                    .makeJson(request: request)
                        }
                    }

            }
    }

    func registerUserHandler(_ request: Request, container: UserRegisterReqContainer) throws -> Future<Response> {
        return UserAuth
            .query(on: request)
            .filter(\.identityType == UserAuth.AuthType.email.rawValue)
            .filter(\.identifier == container.email)
            .first()
            .flatMap{ existAuth in
                guard existAuth == nil else {
                    throw ApiError(code: .modelExisted)
                }
                var userAuth = UserAuth(userId: nil, identityType: .email, identifier: container.email, credential: container.password)
                try userAuth.validate()
                let newUser = User(name: container.name,
                                   email: container.email)
                return newUser
                    .create(on: request)
                    .flatMap { user in
                        userAuth.userId = try user.requireID()
                        return try userAuth
                            .userAuth(with: request.make(BCryptDigest.self))
                            .create(on: request)
                            .flatMap { _ in
                                return try self.sendRegisteMail(user: user, request: request)
                            }.flatMap { _ in
                                return try self.authService.authenticationContainer(for: user.requireID(), on: request)
                            }
                    }
            }
        }
}

extension UserAuth {
    func userAuth(with digest: BCryptDigest) throws -> UserAuth {
        return try UserAuth(userId: userId, identityType: .type(identityType), identifier: identifier, credential: digest.hash(credential))
    }
}


