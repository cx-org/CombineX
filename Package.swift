// swift-tools-version:5.0

import PackageDescription

/*
 for cli test:
 
 `swift test`: test CombineX
 `swift test -Xswiftc -DUSE_COMBINE`: test Combine
 */
let platforms: [SupportedPlatform]
let settings: [SwiftSetting]?

#if USE_COMBINE
platforms = [
    .macOS("10.15")
]
#else
platforms = [
    .macOS(.v10_10),
    .iOS(.v8),
    .tvOS(.v9),
    .watchOS(.v2)
]
#endif

/*
 for xcode test:
 
 change `useCombine` to `true` to test Combine with Xcode
 */
let useCombine = false
let swiftSettings: [SwiftSetting]? = useCombine ? [.define("USE_COMBINE")] : nil

let package = Package(
    name: "CombineX",
    platforms: platforms,
    products: [
        .library(name: "CombineX", targets: ["CombineX"])
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "2.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),
    ],
    targets: [
        .target(name: "CombineX"),
        .testTarget(name: "CombineXTests", dependencies: ["CombineX", "Quick", "Nimble"], swiftSettings: swiftSettings)
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
