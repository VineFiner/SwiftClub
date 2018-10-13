//
//  middlewares.swift
//  App
//
//  Created by laijihua on 2018/8/29.
//

import Vapor
import Authentication

public func middlewares(config: inout MiddlewareConfig, env: inout Environment) throws {
    // https://github.com/vapor/documentation/blob/7ae18772483e4763f1f4000437dc34d1f46ecbe3/3.0/docs/vapor/middleware.md
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    config.use(CORSMiddleware(configuration: corsConfiguration))

    config.use(APIErrorMiddleware(environment: env, specializations: [
        ModelNotFound()
    ]))
}
