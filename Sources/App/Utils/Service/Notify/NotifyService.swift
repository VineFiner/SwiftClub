//
//  NotifyService.swift
//  App
//
//  Created by laijihua on 2018/8/27.
//

import Foundation
import Vapor

import Fluent
import FluentPostgreSQL
import Pagination


extension NotifyService {
    enum TargetType: String {
        case user = "user"
        case question = "question"
        case topic = "topic"
    }

    enum Action: String {
        case like = "like"      // 喜欢 | 收藏
        case comment = "comment" // 评论
        case post = "post" // 发布
        case liked = "liked" // 被喜欢
        case commented = "commented" // 被评论
    }

    enum Reason: String {
        case likeUser = "likeUser" // 关注用户
        case likeTopic = "likeTopic" // 关注文章
        case likeQuestion = "likeQuestion" // 关注的问题

        var actions: [Action] {
            switch self {
            case .likeUser:
                return [.like, .comment, .post]
            case .likeTopic:
                return [.comment, .like]
            case .likeQuestion:
                return [.comment, .like]
            }
        }
    }
    // 自己创建的文章|问答被评论
    // 自己创建的文章|问答被收藏
    // 自己被粉丝关注

    // 关注的人发布文章|问答
    // 关注的人对文章|问答进行评论
    // 关注的人对文章|问答进行收藏
}

final class NotifyService {

    /// MARK - Create
    /// 往Notify表中插入一条公告记录，
    func createAnnouce(content: String, sender: User.ID, on reqeust: Request) throws -> Future<Response> {
        let notify = Notify(type: Notify.announce, target: nil, targetType: nil, action: nil, sender: sender, content: content)
        return try notify.create(on: reqeust).makeJson(on: reqeust)
    }

    /// 往Notify表中插入一条提醒记录
    func createRemind(target: Int, targetType: TargetType, action: Action, sender: User.ID, content: String, on reqeust: Request) throws -> Future<Response> {
        let notify = Notify(type: Notify.remind, target: target, targetType: targetType.rawValue, action: action.rawValue, sender: sender, content: content)
        return try notify.create(on: reqeust).makeJson(on: reqeust)
    }

    /// 往Notify表中插入一条信息记录
    /// 往UserNotify表中插入一条记录，并关联新建的Notify
    func createMessage(content: String, senderId: User.ID, receiverId: User.ID, on reqeust: Request) throws -> Future<Response> {
        let notify = Notify(type: Notify.message, target: nil, targetType: nil, action: nil, sender: senderId, content: content)
        return try notify
            .create(on: reqeust)
            .flatMap(to: UserNotify.self , { noti in
                let notid = try noti.requireID()
                let userNotify = UserNotify(userId: receiverId, notifyId: notid, notifyType: noti.type)
                return userNotify.create(on: reqeust)
            }).makeJson(on: reqeust)
    }

    ///MARK - Accessible
    /// 获取用户的消息列表
    func getUserNotify(userId: User.ID, on reqeust: Request) throws -> Future<Response>{
        return try UserNotify
            .query(on: reqeust)
            .filter(\UserNotify.userId == userId)
            .sort(\UserNotify.createdAt)
            .range(reqeust.pageRange)
            .join(\UserNotify.notifyId, to: \Notify.id)
            .alsoDecode(Notify.self)
            .all()
            .map { tupels in
                return tupels.map {tuple in
                    return NotifyResContainer(userNotify: tuple.0, notify: tuple.1)
                }
             }
            .flatMap { results in
                return UserNotify.query(on: reqeust).filter(\UserNotify.userId == userId).count().map(to: Paginated<NotifyResContainer>.self, { count in
                    return reqeust.paginated(data: results, total: count)
                })
            }.makeJson(on: reqeust)
    }

    /// 更新指定的notify，把isRead属性设置为true
    func read(user: User, notifyIds:[Notify.ID], on reqeust: Request) throws -> Future<Void>{
        let userId = try user.requireID()
        return UserNotify
            .query(on: reqeust)
            .filter(\UserNotify.userId == userId)
            .filter(\UserNotify.notifyId ~~ notifyIds)
            .update(\UserNotify.isRead, to: true)
            .all()
            .map(to: Void.self, { _ in Void()})
    }

    func createUserNotify(userId: User.ID, notifies: [Notify], on request: Request) throws -> Future<Void> {
        let futures = notifies.map { notify -> Future<Void> in
            let userNoti = UserNotify(userId: userId, notifyId: notify.id!, notifyType: notify.type)
            return userNoti.create(on: request).map(to: Void.self, {_ in })
        }
        return Future<Void>.andAll(futures, eventLoop: request.eventLoop)
    }


    /// 从UserNotify中获取最近的一条公告信息的创建时间
    /// 用lastTime作为过滤条件，查询Notify的公告信息
    /// 新建UserNotify并关联查询出来的公告信息
    func pullAnnounce(userId: User.ID, on request: Request) throws -> Future<Response> {
        return UserNotify
            .query(on: request)
            .filter(\.userId == userId)
            .filter(\UserNotify.notifyType == Notify.announce)
            .sort(\UserNotify.createdAt, .descending)
            .first()
            .flatMap { usernoti in
                /// 获取到最后一条
                guard let existUsernoti = usernoti,
                    let lastTime = existUsernoti.createdAt else {
                    return try request.makeJson()
                }

                return try Notify
                    .query(on: request)
                    .filter(\.type == Notify.announce)
                    .filter(\.createdAt > lastTime)
                    .all()
                    .flatMap{ noties in
                       return try self.createUserNotify(userId: userId, notifies: noties, on: request)
                    }.makeJson(request: request)
        }

    }

    /// 查询用户的订阅表，得到用户的一系列订阅记录
    /// 通过每一条的订阅记录的target、targetType、action、createdAt去查询Notify表，获取订阅的Notify记录。（注意订阅时间必须早于提醒创建时间）
    /// 查询用户的配置文件SubscriptionConfig，如果没有则使用默认的配置DefaultSubscriptionConfig
    /// 使用订阅配置，过滤查询出来的Notify
    /// 使用过滤好的Notify作为关联新建UserNotify
    func pullRemind(userId: User.ID, on request: Request) throws -> Future<Response> {
        return try Subscription
            .query(on: request)
            .filter(\.userId == userId)
            .all()
            .flatMap { subs in
                // 二维数组
                let noties = subs.compactMap { sub in
                    return Notify
                        .query(on: request)
                        .filter(\Notify.type == sub.target)
                        .filter(\Notify.targetType == sub.targetType)
                        .filter(\Notify.action == sub.action)
                        .filter(\Notify.createdAt > sub.createdAt)
                        .all()
                }
                let allFutures = noties.map { notifyF in
                    return notifyF.flatMap { notis -> EventLoopFuture<Void> in
                        return try self.createUserNotify(userId: userId, notifies: notis, on: request)
                    }
                }
                return Future<Void>.andAll(allFutures, eventLoop: request.eventLoop)
            }.makeJson(request: request)
    }


    /// 通过reason，查询reasonAction，获取对应的动作组:actions
    /// 遍历动作组，每一个动作新建一则Subscription记录
    func subscribe(userId: User.ID, target: Int, targetType: TargetType, reason: Reason, on reqeust: Request) throws -> Future<Response>{

        let futures = reason.actions.map { action -> EventLoopFuture<Void> in
            let subscribe = Subscription(target: target, targetType: targetType.rawValue, userId: userId, action: action.rawValue)
            return subscribe.create(on: reqeust).map(to: Void.self, { _ in return})
        }
        return try Future<Void>.andAll(futures, eventLoop: reqeust.eventLoop).makeJson(request: reqeust)
    }

    //// 删除user、target、targetType对应的一则或多则记录
    func cancelSubscription(userId: User.ID, target: Int, targetType: TargetType, on reqeust: Request) throws -> Future<Response> {
        return try Subscription.query(on: reqeust)
            .filter(\.userId == userId)
            .filter(\.target == target)
            .filter(\.targetType == targetType.rawValue)
            .delete()
            .makeJson(request: reqeust)
    }

    //// 查询SubscriptionConfig表，获取用户的订阅配置
    func getSubscriptionConfig(userId: User.ID, on reqeust: Request) throws -> Future<Response> {
        return try Subscription.query(on: reqeust)
            .filter(\.userId == userId)
            .all()
            .makeJson(on: reqeust)
    }
}
