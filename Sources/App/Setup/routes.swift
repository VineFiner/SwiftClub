import Vapor
import Leaf
//import Jobs

public func routes(_ router:Router, _ container:Container) throws {

    // / 用于静态文件
    router.get("welcome") { req in
        return "welcome"
    }

    let group = router.grouped("api")
    let authRouteController = AuthenticationRouteController()
    try group.register(collection: authRouteController)
    
    let userRouteController = UserRouteController()
    try group.register(collection: userRouteController)

    let protectedRouteController = ProtectedRoutesController()
    try group.register(collection: protectedRouteController)

    let accountRouteController = AccountRouteController()
    try group.register(collection: accountRouteController)

    let topicRouteController = TopicRouteController()
    try group.register(collection: topicRouteController)

}

