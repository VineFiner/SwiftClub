//
//  JSONContainer.swift
//  App
//
//  Created by laijihua on 2018/6/20.
//

import Vapor

/// 封装成 struct 优于 enum.
struct ResponseStatus: Content {
    var code: UInt
    var desc: String

    static var ok = ResponseStatus(code: 0, desc: "请求成功")
    /// 接口失败
    static var userExist = ResponseStatus(code: 20, desc: "用户已经存在")
    static var userNotExist = ResponseStatus(code: 21, desc: "用户不存在")
    static var passwordError = ResponseStatus(code: 22, desc: "密码错误")
    static var emailNotExist = ResponseStatus(code: 23, desc: "邮箱不存在")
    static var bookNotExist = ResponseStatus(code: 24, desc: "书籍不存在")
    static var modelNotExist = ResponseStatus(code: 25, desc: "对象不存在")
    static var modelExisted = ResponseStatus(code: 26, desc: "对象已存在")
    static var authFail = ResponseStatus(code: 27, desc: "认证失败")
    static var codeFail = ResponseStatus(code: 28, desc: "验证码错误")
    static var resonNotExist = ResponseStatus(code: 29, desc: "不存在reason")
    static var base64DecodeError = ResponseStatus(code: 30, desc: "base64 decode 失败")
    static var custom = ResponseStatus(code: 31, desc: "出错了")
    static var refreshTokenNotExist = ResponseStatus(code: 32, desc: "refreshToken 不存在")


    // 用于修改
    mutating func message(_ str: String) {
        self.desc = str
    }
}

struct Empty: Content {}

struct JSONContainer<D: Content>: Content {
    private var status: ResponseStatus
    private var message: String
    private var data: D?

    static var successEmpty: JSONContainer<Empty> {
        return JSONContainer<Empty>()
    }

    init(data:D? = nil) {
        self.status = .ok
        self.message = self.status.desc
        self.data = data
    }

    init(data: D) {
        self.status = .ok
        self.message = status.desc
        self.data = data
    }

    static func success(data: D) -> JSONContainer<D> {
        return JSONContainer(data:data)
    }
}

extension Future where T: Content {
    func makeJson(on request: Request) throws -> Future<Response> {
        return try self.map { data in
            return JSONContainer(data: data)
        }.encode(for: request)
    }
}

extension Future where T == Void {
    func makeJson(request: Request) throws -> Future<Response> {
        return try self.transform(to: JSONContainer<Empty>.successEmpty).encode(for: request)
    }
}

extension Request {
    func makeJson<T: Content>(_ content: T) throws -> Future<Response> {
        return try JSONContainer<T>(data: content).encode(for: self)
    }

    /// Void json
    func makeJson() throws -> Future<Response> {
        return try JSONContainer<Empty>(data: nil).encode(for: self)
    }
}
