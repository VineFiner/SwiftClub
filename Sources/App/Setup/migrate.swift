//
//  migrate.swift
//  App
//
//  Created by laijihua on 2018/8/29.
//

import Vapor
import FluentPostgreSQL //use your database driver here

public func migrate(migrations: inout MigrationConfig) throws {
    migrations.add(model: Organization.self, database: .psql)
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Menu.self, database: .psql)
    migrations.add(model: Role.self, database: .psql)
    migrations.add(model: OpLog.self, database: .psql)
    migrations.add(model: Right.self, database: .psql)
    migrations.add(model: Group.self, database: .psql)
    migrations.add(model: RoleRight.self, database: .psql)
    migrations.add(model: GroupRight.self, database: .psql)
    migrations.add(model: GroupRole.self, database: .psql)
    migrations.add(model: UserRight.self, database: .psql)
    migrations.add(model: UserRole.self, database: .psql)
    migrations.add(model: UserGroup.self, database: .psql)
    migrations.add(model: AccessToken.self, database: .psql)
    migrations.add(model: RefreshToken.self, database: .psql)
    migrations.add(model: ActiveCode.self, database: .psql)
    migrations.add(model: Notify.self, database: .psql)
    migrations.add(model: UserNotify.self, database: .psql)
    migrations.add(model: Subscription.self, database: .psql)
    migrations.add(model: UserAuth.self, database: .psql)

    /// Club
    migrations.add(model: Subject.self, database: .psql)
    migrations.add(model: Topic.self, database: .psql)
    migrations.add(model: Comment.self, database: .psql)
    migrations.add(model: Replay.self, database: .psql)

    /// Photo
    migrations.add(model: PhotoCategory.self, database: .psql)
    migrations.add(model: Photo.self, database: .psql)
    migrations.add(model: PhotoComment.self, database: .psql)

    // Populate 预填充
    migrations.add(migration: PopulateOrganizationForms.self, database: .psql)
    migrations.add(migration: PopulateMenuForms.self, database: .psql)
    migrations.add(migration: PopulateSubjectForms.self, database: .psql)
    migrations.add(migration: PopulatePhotoCategoryForms.self, database: .psql)

    // 添加字段, 如果你是最新的项目，那么下面的进行注释
    //migrations.add(migration: SubjectAddIcon.self, database: .psql)
}
