// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "Saby",
    products: [
        .library(
            name: "Saby",
            targets: ["SabyCollection", "SabyConcurrency"]),
        .library(
            name: "SabyCollection",
            targets: ["SabyCollection"]),
        .library(
            name: "SabyConcurrency",
            targets: ["SabyConcurrency"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SabyCollection",
            dependencies: [],
            path: "Source/Collection"),
        .target(
            name: "SabyConcurrency",
            dependencies: [],
            path: "Source/Concurrency"),
        .testTarget(
            name: "SabyCollectionTest",
            dependencies: ["SabyCollection"],
            path: "Test/Collection"),
        .testTarget(
            name: "SabyConcurrencyTest",
            dependencies: ["SabyConcurrency"],
            path: "Test/Concurrency"),
    ]
)
