// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Interval",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "AppCore",
            targets: ["AppCore"]),
        .library(
            name: "AppUI",
            targets: ["AppUI"]),
        .library(
            name: "IntervalCore",
            targets: ["IntervalCore"]),
        .library(
            name: "IntervalUI",
            targets: ["IntervalUI"]),
        .library(
            name: "IntervalList",
            targets: ["IntervalList"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.39.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AppCore",
            dependencies: [
                "IntervalCore",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "AppUI",
            dependencies: [
                "AppCore",
                "IntervalUI",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "IntervalCore",
            dependencies: [.product(name: "ComposableArchitecture", package: "swift-composable-architecture")]
        ),
        .target(
            name: "IntervalUI",
            dependencies: [
                "IntervalCore",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "IntervalList",
            dependencies: [
                "IntervalCore",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "IntervalCoreTests",
            dependencies: ["IntervalCore"]
        ),
    ]
)
