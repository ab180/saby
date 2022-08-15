// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "Saby",
    products: [
        .library(
            name: "Saby",
            targets: ["SabyConcurrency", "SabyJSON", "SabySafe"]),
        .library(
            name: "SabyConcurrency",
            targets: ["SabyConcurrency"]),
        .library(
            name: "SabyJSON",
            targets: ["SabyJSON"]),
        .library(
            name: "SabySafe",
            targets: ["SabySafe"]), 
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SabyConcurrency",
            dependencies: [],
            path: "Source/Concurrency"),
        .target(
            name: "SabyJSON",
            dependencies: [],
            path: "Source/JSON"),
        .target(
            name: "SabySafe",
            dependencies: [],
            path: "Source/Safe"),
        .testTarget(
            name: "SabyConcurrencyTest",
            dependencies: ["SabyConcurrency"],
            path: "Test/Concurrency"),
        .testTarget(
            name: "SabyJSONTest",
            dependencies: ["SabyJSON"],
            path: "Test/JSON"),
        .testTarget(
            name: "SabySafeTest",
            dependencies: ["SabySafe"],
            path: "Test/Safe"),
    ]
)
