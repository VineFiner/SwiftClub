//
//  TopicRouteController.swift
//  App
//
//  Created by laijihua on 2018/10/17.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL
import Pagination
import Leaf


final class TopicRouteController: RouteCollection {

    let notifyService = NotifyService()

    func boot(router: Router) throws {
        let group = router.grouped("topic")
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])

        // 添加
        group.get("subjects", use: subjectsList) // 获取板块
        group.get("tags", use: tagsList) // tags
        group.get("list", use: topicList) // 获取话题列表

        // 获取 html
        group.get(Topic.parameter, use: topicFetch) // topic 详情
        group.get(Topic.parameter, "html", use: topicHtml)

        // 添加文章
        tokenAuthGroup.post(TopicReqContainer.self, at: "add", use: topicAdd)
        // 板块添加
        tokenAuthGroup.post(Subject.self, at: "subject", "add", use: topicSubjectAdd)
        // 添加tag
        tokenAuthGroup.post(TagReqContainer.self, at: "tag", "add", use: tagAdd)
    }
}


extension TopicRouteController {
    func topicHtml(request: Request) throws -> Future<View> {
        return try request.parameters
            .next(Topic.self)
            .flatMap { tmp in
                return try request.view().render("markdown", ["myMarkdown": tmp.content])
        }
    }

    // 添加评论回复
    func commentAddReplay(request: Request, replay: Replay) throws  -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return try replay.create(on: request).makeJson(on: request)
    }

    // MARK: - Detail
    /// 获取话题
    func topicFetch(request: Request) throws -> Future<Response> {
        return try request.parameters.next(Topic.self).flatMap(to: TopicResContainer.self) { topic in
            return topic
                .creator
                .query(on: request)
                .first()
                .unwrap(or: ApiError(code: .modelNotExist))
                .map(to: TopicResContainer.self) { user in
                    return TopicResContainer(topic: topic, user: user)
            }
            }.makeJson(on:request)
    }

    // MARK: - List
    func tagsList(request: Request) throws -> Future<Response> {
        return try Tag.query(on: request).all().makeJson(on: request)
    }

    /// 获取主题列表
    func subjectsList(request: Request) throws -> Future<Response> {
        return try Subject.query(on: request).all().makeJson(on: request)
    }

    func topicList(request: Request) throws -> Future<Response> {
        let subjectId = try request.query.get(Int?.self, at: "subjectId")
        if let subjectId = subjectId {  //
            return try Topic
                .query(on: request)
                .filter(\Topic.subjectId == subjectId)
                .sort(\Topic.createdAt, .descending)
                .range(request.pageRange) // 获取分页数据
                .join(\User.id, to: \Topic.userId)
                .alsoDecode(User.self)
                .all()
                .map { tuples in
                    return tuples.map { tuple in  return TopicResContainer(topic: tuple.0, user: tuple.1)}
                }.flatMap{ results in
                    return Topic.query(on: request)
                        .filter(\Topic.subjectId == subjectId)
                        .count()
                        .map(to: Paginated<TopicResContainer>.self) { count in
                        return request.paginated(data: results, total: count)
                    }
                }
                .makeJson(on:request)
        } else { // 全部数据
            return try Topic
                .query(on: request)
                .sort(\Topic.createdAt, .descending)
                .range(request.pageRange) // 获取分页数据
                .join(\User.id, to: \Topic.userId)
                .alsoDecode(User.self)
                .all()
                .map { tuples in
                    return tuples.map { tuple in  return TopicResContainer(topic: tuple.0, user: tuple.1)}
                }.flatMap{ results in
                    return Topic.query(on: request).count().map(to: Paginated<TopicResContainer>.self) { count in
                        return request.paginated(data: results, total: count)
                    }
                }
                .makeJson(on:request)
        }
    }

    // MARK: - ADD
    func tagAdd(request: Request, container: TagReqContainer) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self) // 获取到当前用户
        let tag = Tag(name: container.name, remarks: container.remarks)
        return try tag.create(on: request).makeJson(on: request)
    }

    func topicAdd(request: Request, container: TopicReqContainer) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self) // 获取到当前用户
        let topic = Topic(title: container.title,
                          subjectId: container.subjectId,
                          userId: container.userId,
                          content: container.content,
                          textType: Topic.TextType(type: container.textType))
        return topic
            .create(on: request)
            .flatMap { topic in
                let topicId = topic.id!
                return container.tags
                    .map { tagId in
                        return TopicTag(tagId: tagId, topicId: topicId).save(on: request)
                    }
                    .flatten(on: request)
                    .flatMap { tags in
                    /// xxx发布了 这个 xxx topic，标题是 xxx
                    return try self.notifyService.createRemind(target: topic.id!, targetType: .topic, action: .post, sender: topic.userId, content: topic.title, on: request)
                }
            }
    }

    func topicSubjectAdd(request: Request, container: Subject) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return try container.create(on: request).makeJson(on: request)
    }
}

