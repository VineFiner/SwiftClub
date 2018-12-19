import Routing
import Vapor
import Redis


public func routes(_ router: Router) throws {

    // / 用于静态文件
    router.get("welcome") { req in
        return "welcome"
    }

    router.get("senderEmail") { request in
        return try EmailSender.sendEmail(request, content: .accountActive(emailTo: "1164258202@qq.com", url: "https://baidu.com")).transform(to: HTTPStatus.ok)
    }

    router.get("user") { request in
        return try User.query(on: request).paginate(for: request).map{$0.response()}.makeJson(on: request)
    }

    router.get("redis") { request in
        return request.withNewConnection(to: .redis, closure: { redis in
            return redis.command("INFO")
                .map { $0.string ?? "" }
        })
    }

    let authRouteController = AuthenticationRouteController()
    try router.register(collection: authRouteController)

    let userRouteController = UserRouteController()
    try router.register(collection: userRouteController)

    let sysRouteController = SysRouteController()
    try router.register(collection: sysRouteController)

    let protectedRouteController = ProtectedRoutesController()
    try router.register(collection: protectedRouteController)

    let accountRouteController = AccountRouteController()
    try router.register(collection: accountRouteController)

    let newsRouteController = NewsRouteController()
    try router.register(collection: newsRouteController)

    let topicRouteController = TopicRouteController()
    try router.register(collection: topicRouteController)

    let photoRouteController = PhotoRouteController()
    try router.register(collection: photoRouteController)

    let informationController = InformationController()
    try router.register(collection: informationController)

    let questionController = QuestionController()
    try router.register(collection: questionController)
}

