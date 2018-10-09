import Routing
import Vapor


public func routes(_ router: Router) throws {

    router.get("welcome") { req in
        return "welcome"
    }

    router.get("senderEmail") { request in
        return try EmailSender.sendEmail(request, content: .accountActive(emailTo: "1164258202@qq.com", url: "https://baidu.com")).transform(to: HTTPStatus.ok)
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
}
