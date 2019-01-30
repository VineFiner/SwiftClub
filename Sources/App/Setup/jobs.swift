//
//  jobs.swift
//  App
//
//  Created by laijihua on 2019/1/29.
//

/*
import Foundation
import Vapor
import Jobs
import FluentPostgreSQL

public func jobs(_ services: inout Services) throws {
    /// jobs
    let jobsProvider = JobsProvider(refreshInterval: .seconds(10))
    try services.register(jobsProvider)

    let notifiServer = NotifyService()
    services.register { _ -> NotifyService in
        return notifiServer
    }

    var jobContext = JobContext()
    jobContext.notifyService = notifiServer
    services.register { container -> JobContext in
        jobContext.container = container
        return jobContext
    }
    // Register jobs
    services.register { _ -> JobsConfig in
        var jobsConfig = JobsConfig()
        jobsConfig.add(NotifyPullJob.self)
        return jobsConfig
    }

    services.register { _ -> CommandConfig in
        var commandConfig = CommandConfig.default()
        commandConfig.use(JobsCommand(), as: "jobs")
        return commandConfig
    }
}

struct NotifyPullJob: Job {
    var userId: Int

    init(userId: Int) {
        self.userId = userId
    }

    func dequeue(context: JobContext, worker: EventLoopGroup) -> EventLoopFuture<Void> {
        guard let container = context.container, let notifiservice = context.notifyService else { return worker.future(error: Abort(.badRequest, reason: "Something went wrong"))}
        return container.withNewConnection(to: .psql, closure: { request -> EventLoopFuture<Void> in
            print("yellow ....")
            return try notifiservice.pullRemind(userId: self.userId, on: request)
        })
    }

    func error(context: JobContext, error: Error, worker: EventLoopGroup) -> EventLoopFuture<Void> {
        return worker.future(error: error)
    }
}


extension NotifyService: Service {}

extension JobContext {
    var container: Container? {
        get {
            return userInfo["server-container"] as? Container
        } set {
            userInfo["server-container"] = container
        }
    }

    var notifyService: NotifyService? {
        get {
            return userInfo["service-notify"] as? NotifyService
        }
        set {
            userInfo["service-notify"] = newValue
        }
    }
}
*/
