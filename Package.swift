// swift-tools-version:5.0

import Foundation
import PackageDescription

func testCombine() -> Bool {
//    return true
    
    let env = ProcessInfo.processInfo.environment
    return env["TEST_COMBINE"] != nil
}

var platforms: [SupportedPlatform] = [
    .macOS(.v10_10),
    .iOS(.v8),
    .tvOS(.v9),
    .watchOS(.v2)
]
var swiftSettings: [SwiftSetting]?

if testCombine() {
    platforms = [
        .macOS("10.15")
    ]
    swiftSettings = [.define("USE_COMBINE")]
}

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
        .target(name: "CXUtility"),
        .target(name: "CombineX", dependencies: ["CXUtility"]),
        .testTarget(name: "CombineXTests", dependencies: ["CXUtility", "CombineX", "Quick", "Nimble"], swiftSettings: swiftSettings)
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
