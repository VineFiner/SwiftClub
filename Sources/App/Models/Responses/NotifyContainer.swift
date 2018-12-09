//
//  NotifyContainer.swift
//  App
//
//  Created by laijihua on 2018/12/9.
//

import Vapor

struct NotifyContainer: Content {
    var userNotify: UserNotify
    var notify: Notify
    init(userNotify: UserNotify, notify: Notify) {
        self.userNotify = userNotify
        self.notify = notify;
    }
}
