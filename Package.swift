// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "SwiftClub",
    products: [
        .executable(name: "Run", targets: ["Run"]),
        .library(name: "App", targets: ["App"]),
        .executable(name: "AppTests", targets: ["AppTests"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.1.0"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.1"),
        .package(url: "https://github.com/vapor-community/pagination.git", from: "1.0.7"),
        .package(url: "https://github.com/IBM-Swift/Swift-SMTP", .upToNextMinor(from: "5.1.0"))
    ],
    targets: [
        .target(name: "App", dependencies: [
            "Vapor",
            "Authentication",
            "SwiftSMTP",
            "Pagination",
            "FluentPostgreSQL"
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

