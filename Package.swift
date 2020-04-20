// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MCTS-TicketToRide",
    products: [
        .executable(name: "TTR", targets: ["MCTS-TicketToRide"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/jmmaloney4/Squall.git", from: "1.2.3"),
        .package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", from: "17.0.0"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.0.1")),
        .package(url: "https://github.com/uber/swift-concurrency.git", from: "0.7.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "MCTS-TicketToRide",
            dependencies: ["Squall", "SwiftyJSON", "PathKit", "ArgumentParser", "Concurrency"]
        ),
        .testTarget(
            name: "MCTS-TicketToRideTests",
            dependencies: ["MCTS-TicketToRide"]
        ),
    ]
)
