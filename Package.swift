// swift-tools-version: 5.6
import PackageDescription

var package = Package(
    name: "Saby",
    products: [
        .library(
            name: "SabyConcurrency",
            targets: ["SabyConcurrency"]),
        .library(
            name: "SabyESCArchitecture",
            targets: ["SabyESCArchitecture"]),
        .library(
            name: "SabyExpect",
            targets: ["SabyExpect"]),
        .library(
            name: "SabyJSON",
            targets: ["SabyJSON"]),
        .library(
            name: "SabyMock",
            targets: ["SabyMock"]),
        .library(
            name: "SabyNetwork",
            targets: ["SabyNetwork"]),
        .library(
            name: "SabyNumeric",
            targets: ["SabyNumeric"]),
        .library(
            name: "SabySafe",
            targets: ["SabySafe"]),
        .library(
            name: "SabyTime",
            targets: ["SabyTime"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SabyConcurrency",
            dependencies: [],
            path: "Source/Concurrency"),
        .target(
            name: "SabyESCArchitecture",
            dependencies: ["SabyConcurrency"],
            path: "Source/ESCArchitecture"),
        .target(
            name: "SabyExpect",
            dependencies: ["SabyConcurrency"],
            path: "Source/Expect"),
        .target(
            name: "SabyJSON",
            dependencies: [],
            path: "Source/JSON"),
        .target(
            name: "SabyMock",
            dependencies: ["SabyJSON"],
            path: "Source/Mock"),
        .target(
            name: "SabyNetwork",
            dependencies: ["SabyConcurrency", "SabyJSON", "SabySafe"],
            path: "Source/Network"),
        .target(
            name: "SabyNumeric",
            dependencies: [],
            path: "Source/Numeric"),
        .target(
            name: "SabySafe",
            dependencies: [],
            path: "Source/Safe"),
        .target(
            name: "SabyTime",
            dependencies: [],
            path: "Source/Time"),
        .testTarget(
            name: "SabyConcurrencyTest",
            dependencies: ["SabyConcurrency"],
            path: "Test/Concurrency"),
        .testTarget(
            name: "SabyJSONTest",
            dependencies: ["SabyJSON"],
            path: "Test/JSON"),
        .testTarget(
            name: "SabyNetworkTest",
            dependencies: ["SabyNetwork", "SabyMock", "SabyExpect"],
            path: "Test/Network"),
        .testTarget(
            name: "SabyNumericTest",
            dependencies: ["SabyNumeric"],
            path: "Test/Numeric"),
        .testTarget(
            name: "SabySafeTest",
            dependencies: ["SabySafe"],
            path: "Test/Safe"),
        .testTarget(
            name: "SabyTimeTest",
            dependencies: ["SabyTime"],
            path: "Test/Time"),
    ]
)

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
package
    .products.append(contentsOf: [
        .library(
            name: "SabyAppleObjectiveCReflection",
            targets: ["SabyAppleObjectiveCReflection"]
        ),
        .library(
            name: "SabyAppleDataFetcher",
            targets: ["SabyAppleDataFetcher"]
        ),
        .library(
            name: "SabyAppleStorage",
            targets: ["SabyAppleStorage"]
        ),
        .library(
            name: "SabyAppleLogger",
            targets: ["SabyAppleLogger"]
        )
    ])

package
    .targets.append(contentsOf: [
        .target(
            name: "SabyAppleDataFetcher",
            dependencies: ["SabyAppleObjectiveCReflection", "SabyConcurrency"],
            path: "Source/AppleDataFetcher"),
        .target(
            name: "SabyAppleStorage",
            dependencies: ["SabyConcurrency", "SabySafe"],
            path: "Source/AppleStorage"),
        .target(
            name: "SabyAppleLogger",
            dependencies: [],
            path: "Source/AppleLogger"),
        .target(
            name: "SabyAppleObjectiveCReflection",
            dependencies: [],
            path: "Source/AppleObjectiveCReflection"),
        .testTarget(
            name: "SabyAppleStorageTest",
            dependencies: ["SabyAppleStorage", "SabySafe"],
            path: "Test/AppleStorage"),
        .testTarget(
            name: "SabyAppleLoggerTest",
            dependencies: ["SabyAppleLogger"],
            path: "Test/AppleLogger"),
        .testTarget(
            name: "SabyAppleObjectiveCReflectionTest",
            dependencies: ["SabyAppleObjectiveCReflection"],
            path: "Test/AppleObjectiveCReflection")
    ])
#endif
