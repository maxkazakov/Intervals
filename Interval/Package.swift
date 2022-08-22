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
            name: "WorkoutPlanCore",
            targets: ["WorkoutPlanCore"]),
        .library(
            name: "WorkoutPlanUI",
            targets: ["WorkoutPlanUI"]),
        .library(
            name: "WorkoutPlansListCore",
            targets: ["WorkoutPlansListCore"]),
        .library(
            name: "WorkoutPlansListUI",
            targets: ["WorkoutPlansListUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.39.0"),
    ],
    targets: [
        .target(
            name: "AppCore",
            dependencies: [
                "WorkoutPlansListCore",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "AppUI",
            dependencies: [
                "AppCore",
                "WorkoutPlansListUI",
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
            name: "WorkoutPlanCore",
            dependencies: [
                "IntervalCore",
            ]
        ),
        .target(
            name: "WorkoutPlanUI",
            dependencies: [
                "IntervalUI",
                "WorkoutPlanCore"
            ]
        ),
        .target(
            name: "WorkoutPlansListCore",
            dependencies: [
                "WorkoutPlanCore"
            ]
        ),
        .target(
            name: "WorkoutPlansListUI",
            dependencies: [
                "WorkoutPlansListCore",
                "WorkoutPlanUI"
            ]
        ),
        .testTarget(
            name: "IntervalCoreTests",
            dependencies: ["IntervalCore"]
        ),
    ]
)
