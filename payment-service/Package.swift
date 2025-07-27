// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "PaymentService",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        .package(url: "https://github.com/swift-server/swift-kafka-client", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "PaymentService",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Kafka", package: "swift-kafka-client"),
            ]
        )
    ]
)
