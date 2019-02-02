//
//  MiniRouteController.swift
//  App
//
//  Created by laijihua on 2019/2/2.
//

import Vapor
import FluentPostgreSQL
import Crypto

final class MiniRouteController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("api", "mini")
        group.get("apn") { (request) -> String in
            return try request.query.get(String.self, at: "echostr")
//            let token = "miniapn"
//            //        let aeskey = "2882DvzBdImoISNw5Mf13eAsFQrX2xUuGIIlLJlJSB9"
//            let signature = try request.query.get(String.self, at: "signature")
//            let timestamp = try request.query.get(String.self, at: "timestamp")
//            let nonce = try request.query.get(String.self, at: "nonce")
//
//            var tmpArr = [token, timestamp, nonce]
//            tmpArr.sort(by: <)
//            let tmpStr = tmpArr.joined()
//            let tmpSign = try SHA1.hash(tmpStr).hexEncodedString()
//            return tmpSign == signature ? "true":"false"
        }
    }
}

extension MiniRouteController {


}
