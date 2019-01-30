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
import Jobs
import JobsRedisDriver

public func databases(config: inout DatabasesConfig, services: inout Services,env: inout Environment) throws {

    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())
    try services.register(RedisProvider())

    var psqlConfig = PostgreSQLDatabaseConfig(hostname: "127.0.0.1",
                                              port: 5432,
                                              username: "root",
                                              database: "club",
                                              password: "lai12345")

    if (env.isRelease) { /// 发布环境
        psqlConfig = PostgreSQLDatabaseConfig(hostname: "localhost",
                                                  port: 5432,
                                                  username: "dbuser",
                                                  database: "club",
                                                  password: "lai12345")
    }
    config.add(database: PostgreSQLDatabase(config: psqlConfig), as: .psql)

    let redisConfig = RedisClientConfig()
    let redisDatabase = try RedisDatabase(config: redisConfig)
    config.add(database: redisDatabase, as: .redis)

    /// 发布的时候去除控制台输出
    if (!env.isRelease) {
        config.enableLogging(on: .psql)
    }

    /// 添加定时任务
    services.register(JobsPersistenceLayer.self) { container -> JobsRedisDriver in
        return JobsRedisDriver(database: redisDatabase, eventLoop: container.next())
    }

    try jobs(&services)
}
