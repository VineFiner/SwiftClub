// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "SwiftClub",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.3.0"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.1"),
        .package(url: "https://github.com/vapor-community/pagination.git", from: "1.0.7"),
        .package(url: "https://github.com/IBM-Swift/Swift-SMTP.git", .upToNextMinor(from: "5.1.0")),
        .package(url: "https://github.com/vapor/redis.git", from: "3.0.0"), // redis
//        .package(url: "https://github.com/vapor-community/jobs-redis-driver.git", from: "0.2.0"), // job
        .package(url: "https://github.com/vapor-community/leaf-markdown.git", .upToNextMajor(from: "2.0.0"))
//        .package(url: "https://github.com/vapor-community/VaporMonitoring.git", from: "2.0.0") // ubantu 上使用有问题性能检测
        //.package(url: "https://github.com/OpenKitten/MongoKitten.git", from: "4.1.3") // mongodb
    ],
    targets: [
        .target(name: "App", dependencies: [
            "Vapor",
            "Authentication",
            "SwiftSMTP",
            "Pagination",
            "FluentPostgreSQL",
            "Redis",
            "LeafMarkdown"
//            "VaporMonitoring"
            //"MongoKitten"
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

