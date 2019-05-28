//
//  databases.swift
//  App
//
//  Created by laijihua on 2018/8/29.
//

import Vapor
import FluentPostgreSQL
import Authentication
import Redis


public func databases(config: inout DatabasesConfig, services: inout Services,env: inout Environment) throws {

    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())
    try services.register(RedisProvider())


    let db = Environment.get("POSTGRES_DB") ?? "club"
    let pgHost = Environment.get("POSTGRES_HOST") ?? "127.0.0.1"
    let pgUser = Environment.get("POSTGRES_USER") ?? "dbuser"
    let pgPass = Environment.get("POSTGRES_PASSWORD") ?? "lai12345"
    var pgPort = 5432
    if let pgPortParam = Environment.get("POSTGRES_PORT"), let newPort = Int(pgPortParam) {
        pgPort = newPort
    }

    /// macos 设置了 trust， 所以不用密码也可以
    var psqlConfig = PostgreSQLDatabaseConfig(hostname: "127.0.0.1",
                                              port: 5432,
                                              username: "root",
                                              database: "club",
                                              password: nil)

    if (env.isRelease) { /// 发布环境
        psqlConfig = PostgreSQLDatabaseConfig(hostname: pgHost,
                                                  port: pgPort,
                                                  username: pgUser,
                                                  database: db,
                                                  password: pgPass)
    }
    config.add(database: PostgreSQLDatabase(config: psqlConfig), as: .psql)

    var redisConfig = RedisClientConfig()
    redisConfig.hostname = Environment.get("REDIS_HOST") ?? "localhost"
    let redisDatabase = try RedisDatabase(config: redisConfig)
    config.add(database: redisDatabase, as: .redis)

    /// 发布的时候去除控制台输出
    if (!env.isRelease) {
        config.enableLogging(on: .psql)
    }

}
