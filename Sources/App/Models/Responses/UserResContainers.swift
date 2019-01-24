//
//  UserResContainers.swift
//  App
//
//  Created by laijihua on 2019/1/21.
//

import Vapor

/// 用户相关的统计信息
struct UserStatistics: Content {
    var fansCount: Int // 粉丝数
    var followingCount: Int // 关注数
    init(fansCount:Int, followingCount:Int) {
        self.fansCount = fansCount
        self.followingCount = followingCount
    }
}

struct UserIsFollowing: Content {
    var isFollowing: Bool

    init(isFollowing: Bool) {
        self.isFollowing = isFollowing
    }
}

