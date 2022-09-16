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
        .library(
            name: "WorkoutPlansStorage",
            targets: ["WorkoutPlansStorage"]),
        .library(
            name: "ActiveWorkoutCore",
            targets: ["ActiveWorkoutCore"]),
        .library(
            name: "ActiveWorkoutUI",
            targets: ["ActiveWorkoutUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.40.2"),
    ],
    targets: [
        .target(
            name: "AppCore",
            dependencies: [
                "WorkoutPlansListCore",
                "ActiveWorkoutCore",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "AppUI",
            dependencies: [
                "AppCore",
                "WorkoutPlansListUI",
                "ActiveWorkoutUI"
            ]
        ),
        .target(
            name: "IntervalCore",
            dependencies: [.product(name: "ComposableArchitecture", package: "swift-composable-architecture")]
        ),
        .target(
            name: "IntervalUI",
            dependencies: [
                "IntervalCore"
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
                "WorkoutPlanCore",
                "WorkoutPlansStorage",
            ]
        ),
        .target(
            name: "WorkoutPlansListUI",
            dependencies: [
                "WorkoutPlansListCore",
                "WorkoutPlanUI"
            ]
        ),
        .target(
            name: "WorkoutPlansStorage",
            dependencies: [
                "WorkoutPlanCore",
                "IntervalCore"
            ]
        ),
        .target(
            name: "ActiveWorkoutCore",
            dependencies: [
                "WorkoutPlanCore"
            ]
        ),
        .target(
            name: "ActiveWorkoutUI",
            dependencies: [
                "ActiveWorkoutCore"
            ]
        ),

        
        .target(
            name: "TestHelpers"
        ),
        .testTarget(
            name: "IntervalCoreTests",
            dependencies: ["IntervalCore"]
        ),
        .testTarget(
            name: "WorkoutPlanCoreTests",
            dependencies: ["WorkoutPlanCore",
                           "TestHelpers"]
        ),
        .testTarget(
            name: "WorkoutPlansListCoreTests",
            dependencies: ["WorkoutPlansListCore",
                           "TestHelpers"]
        ),
        .testTarget(
            name: "ActiveWorkoutCoreTests",
            dependencies: ["ActiveWorkoutCore",
                           "TestHelpers"]
        ),
    ]
)
