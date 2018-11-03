//
//  QiniuService.swift
//  App
//
//  Created by laijihua on 2018/11/3.
//

import Foundation
import Vapor
import Crypto

final class QiniuService {
    let accessKey: String = "FYdBEAUoeWB4qGnnjrk0z1FG-Wi_EqvIXUAkHkBO"
    let secretKey: String = "EmbLxZU9KsTWILd553l9dqgJ7ryuc7hNUtcCDGtT"

    let scope: String = "twicebook"
    var liveTime: TimeInterval = 5

    static func token() throws -> String {
        return try QiniuService().genery()
    }

    private func genery() throws -> String {
        let date = Date().timeIntervalSince1970 + liveTime * 24 * 3600
        let authInfo: [String: Any] = ["scope": scope,"deadline": Int(date)]
        let jsonData = try JSONSerialization.data(withJSONObject: authInfo, options: .prettyPrinted)
        let encodeString = urlSafeBase64Encode(jsonData)
        let encodedSignedString = try HMACSHA1(secretKey, text: encodeString)
        let token = accessKey + ":" + encodedSignedString + ":" + encodeString
        return token
    }

    private func HMACSHA1(_ key: String, text: String) throws -> String {
        let hmac = try HMAC.SHA1.authenticate(text, key: key)
        let hmacData = hmac.hexEncodedData()
        return urlSafeBase64Encode(hmacData)
    }

    private func urlSafeBase64Encode(_ text: Data) -> String {
        var base64 = text.base64EncodedString()
        base64 = base64.replacingOccurrences(of: "+", with: "-")
        base64 = base64.replacingOccurrences(of: "/", with: "_")
        return base64
    }

}
