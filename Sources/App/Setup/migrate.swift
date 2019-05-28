//
//  migrate.swift
//  App
//
//  Created by laijihua on 2018/8/29.
//

import Vapor
import FluentPostgreSQL //use your database driver here

public func migrate(migrations: inout MigrationConfig) throws {

    migrations.add(model: User.self, database: .psql)
    migrations.add(model: OpLog.self, database: .psql)

    migrations.add(model: AccessToken.self, database: .psql)
    migrations.add(model: RefreshToken.self, database: .psql)
    migrations.add(model: ActiveCode.self, database: .psql)
    migrations.add(model: Notify.self, database: .psql)
    migrations.add(model: UserNotify.self, database: .psql)
    migrations.add(model: Subscription.self, database: .psql)
    migrations.add(model: UserAuth.self, database: .psql)
    migrations.add(model: Relation.self, database: .psql)
    /// ENUM
    /// Club
    migrations.add(model: Subject.self, database: .psql)
    migrations.add(model: Topic.self, database: .psql)
    migrations.add(model: Comment.self, database: .psql)
    migrations.add(model: Replay.self, database: .psql)
    migrations.add(model: Tag.self, database: .psql)
    migrations.add(model: TopicTag.self , database: .psql)
    // Populate 预填
    // 添加字段, 如果你是最新的项目，那么下面的进行注释
//    migrations.add(migration: SubjectAddTopicNum.self, database: .psql)
//    migrations.add(migration: SubjectAddFocusNum.self, database: .psql)
}
