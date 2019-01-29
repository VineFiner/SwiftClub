import Vapor
import Jobs

public func routes(_ router: Router, _ container: Container) throws {

    // / 用于静态文件
    router.get("welcome") { req in
        return "welcome"
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

    let informationController = InformationController()
    try router.register(collection: informationController)

    let questionController = QuestionController()
    try router.register(collection: questionController)

    let queue = try container.make(QueueService.self)
    try router.register(collection: JobsController(queue: queue))

}

