//
//  JobsController.swift
//  App
//
//  Created by laijihua on 2019/1/29.
//

import Vapor
import Jobs

final class JobsController: RouteCollection {
    let queue: QueueService
    init(queue: QueueService) {
        self.queue = queue
    }

    func boot(router: Router) throws {
        /// 添加一个定时任务
        router.get("pull", use: pullNotifiy)
    }
}

extension JobsController {
    func pullNotifiy(req: Request) throws -> Future<HTTPStatus> {
        let job = NotifyPullJob(userId: 1)
        return queue.dispatch(job: job, maxRetryCount: 10).transform(to: .ok)
    }
}
