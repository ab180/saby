// swift-tools-version: 5.6
import PackageDescription

var package = Package(
    name: "Saby",
    products: [
        .library(
            name: "SabyConcurrency",
            targets: ["SabyConcurrency"]),
        .library(
            name: "SabyEncode",
            targets: ["SabyEncode"]),
        .library(
            name: "SabyESCArchitecture",
            targets: ["SabyESCArchitecture"]),
        .library(
            name: "SabyTestExpect",
            targets: ["SabyTestExpect"]),
        .library(
            name: "SabyJSON",
            targets: ["SabyJSON"]),
        .library(
            name: "SabyTestMock",
            targets: ["SabyTestMock"]),
        .library(
            name: "SabyTestWait",
            targets: ["SabyTestWait"]),
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
            name: "SabyEncode",
            dependencies: [],
            path: "Source/Encode"),
        .target(
            name: "SabyESCArchitecture",
            dependencies: ["SabyConcurrency"],
            path: "Source/ESCArchitecture"),
        .target(
            name: "SabyTestExpect",
            dependencies: ["SabyConcurrency"],
            path: "Source/TestExpect"),
        .target(
            name: "SabyTestWait",
            dependencies: ["SabyConcurrency"],
            path: "Source/TestWait"),
        .target(
            name: "SabyJSON",
            dependencies: [],
            path: "Source/JSON"),
        .target(
            name: "SabyTestMock",
            dependencies: ["SabyJSON"],
            path: "Source/TestMock"),
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
            name: "SabyEncodeTest",
            dependencies: ["SabyEncode"],
            path: "Test/Encode"),
        .testTarget(
            name: "SabyJSONTest",
            dependencies: ["SabyJSON"],
            path: "Test/JSON"),
        .testTarget(
            name: "SabyNetworkTest",
            dependencies: ["SabyNetwork", "SabyTestMock", "SabyTestExpect"],
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
            name: "SabyAppleFetcher",
            targets: ["SabyAppleFetcher"]
        ),
        .library(
            name: "SabyAppleHash",
            targets: ["SabyAppleHash"]
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
            name: "SabyAppleFetcher",
            dependencies: ["SabyAppleObjectiveCReflection", "SabyConcurrency"],
            path: "Source/AppleFetcher"),
        .target(
            name: "SabyAppleHash",
            dependencies: [],
            path: "Source/AppleHash"),
        .target(
            name: "SabyAppleStorage",
            dependencies: ["SabyConcurrency"],
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
            name: "SabyAppleHashTest",
            dependencies: ["SabyAppleHash"],
            path: "Test/AppleHash"),
        .testTarget(
            name: "SabyAppleStorageTest",
            dependencies: ["SabyAppleStorage", "SabyTestWait"],
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
