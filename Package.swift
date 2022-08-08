// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "Saby",
    products: [
        .library(
            name: "Saby",
            targets: ["SabyConcurrency", "SabySafe"]),
        .library(
            name: "SabyConcurrency",
            targets: ["SabyConcurrency"]),
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
            name: "SabySafe",
            dependencies: [],
            path: "Source/Safe"),
        .testTarget(
            name: "SabyConcurrencyTest",
            dependencies: ["SabyConcurrency"],
            path: "Test/Concurrency"),
        .testTarget(
            name: "SabySafeTest",
            dependencies: ["SabySafe"],
            path: "Test/Safe"),
    ]
)
