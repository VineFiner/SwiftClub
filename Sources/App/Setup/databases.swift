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


public func databases(config: inout DatabasesConfig, services: inout Services) throws {

    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())
    try services.register(RedisProvider())

    let psqlConfig = PostgreSQLDatabaseConfig(hostname: "localhost",
                                              port: 5432,
                                              username: "root",
                                              database: "club",
                                              password: "lai12345")
    config.add(database: PostgreSQLDatabase(config: psqlConfig), as: .psql)


    let redisConfig = RedisClientConfig()
    config.add(database: try RedisDatabase(config: redisConfig), as: .redis)
    config.enableLogging(on: .psql)
}
