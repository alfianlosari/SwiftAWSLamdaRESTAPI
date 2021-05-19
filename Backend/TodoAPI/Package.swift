// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "TodoAPI",
    platforms: [
        .macOS(.v10_14)
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "0.2.0"),
        .package(url: "https://github.com/soto-project/soto.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "TodoAPI",
            dependencies: [
                .product(name: "SotoDynamoDB", package: "soto"),
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-runtime")
            ]),
        .testTarget(
            name: "TodoAPITests",
            dependencies: ["TodoAPI"]),
    ]
)
