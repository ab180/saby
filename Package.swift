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
            name: "SabySize",
            targets: ["SabySize"]),
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
            dependencies: ["SabyConcurrency", "SabyTestMock"],
            path: "Source/TestWait"),
        .target(
            name: "SabyJSON",
            dependencies: [],
            path: "Source/JSON"),
        .target(
            name: "SabyTestMock",
            dependencies: ["SabyConcurrency", "SabyJSON"],
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
            name: "SabySize",
            dependencies: [],
            path: "Source/Size"),
        .target(
            name: "SabyTime",
            dependencies: [],
            path: "Source/Time"),
        .testTarget(
            name: "SabyConcurrencyTest",
            dependencies: ["SabyConcurrency", "SabyTestWait"],
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
            name: "SabySizeTest",
            dependencies: ["SabySize"],
            path: "Test/Size"),
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
            name: "SabyAppleCrypto",
            targets: ["SabyAppleCrypto"]
        ),
        .library(
            name: "SabyAppleStorage",
            targets: ["SabyAppleStorage"]
        ),
        .library(
            name: "SabyApplePreference",
            targets: ["SabyApplePreference"]
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
            name: "SabyAppleCrypto",
            dependencies: ["SabyTime"],
            path: "Source/AppleCrypto"),
        .target(
            name: "SabyAppleStorage",
            dependencies: ["SabyConcurrency", "SabySize"],
            path: "Source/AppleStorage"),
        .target(
            name: "SabyApplePreference",
            dependencies: ["SabyConcurrency"],
            path: "Source/ApplePreference"),
        .target(
            name: "SabyAppleLogger",
            dependencies: [],
            path: "Source/AppleLogger"),
        .target(
            name: "SabyAppleObjectiveCReflection",
            dependencies: [],
            path: "Source/AppleObjectiveCReflection"),
        .testTarget(
            name: "SabyAppleCryptoTest",
            dependencies: ["SabyAppleCrypto"],
            path: "Test/AppleCrypto"),
        .testTarget(
            name: "SabyAppleStorageTest",
            dependencies: ["SabyAppleStorage", "SabyTestWait"],
            path: "Test/AppleStorage"),
        .testTarget(
            name: "SabyApplePreferenceTest",
            dependencies: ["SabyApplePreference"],
            path: "Test/ApplePreference"),
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
