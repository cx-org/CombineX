// swift-tools-version:5.2

import PackageDescription
import Foundation

var testCombine = ProcessInfo.processInfo.environment["CX_TEST_COMBINE"] != nil
// uncommenet the following line to test against combine
// testCombine = true
let swiftSetting: [SwiftSetting] = testCombine ? [.define("USE_COMBINE")] : [.define("USE_COMBINEX")]
let shimDep: [Target.Dependency] = testCombine ? ["CXCompatible"] : ["CombineX", "CXFoundation"]

let package = Package(
    name: "CombineX",
    products: [
        .library(name: "CombineX", targets: ["CombineX", "CXFoundation"]),
        .library(name: "CXCompatible", targets: ["CXCompatible"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "3.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.0.0"),
        .package(url: "https://github.com/ddddxxx/Semver.git", .upToNextMinor(from: "0.2.1")),
    ],
    targets: [
        .target(name: "CXUtility"),
        .target(name: "CombineX", dependencies: ["CXUtility"]),
        .target(name: "CXFoundation", dependencies: ["CXUtility", "CombineX"]),
        .target(name: "CXCompatible"),
        .target(name: "_CXShim", dependencies: shimDep, swiftSettings: swiftSetting),
        .target(name: "_CXTest", dependencies: ["_CXShim"], swiftSettings: [.define("CX_PRIVATE_SHIM")]),
        .target(name: "CXTestUtility", dependencies: ["CXUtility", "_CXShim", "_CXTest", "Semver", "Quick", "Nimble"], swiftSettings: swiftSetting),
        .testTarget(name: "CombineXTests", dependencies: ["CXTestUtility", "CXUtility", "Quick", "Nimble"], swiftSettings: swiftSetting),
        .testTarget(name: "CXFoundationTests", dependencies: ["CXTestUtility", "Quick", "Nimble"]),
        .testTarget(name: "CXInconsistentTests", dependencies: ["CXTestUtility", "CXUtility", "Quick", "Nimble"]),
    ]
)

if testCombine {
    package.platforms = [.macOS("10.15"), .iOS("13.0"), .tvOS("13.0"), .watchOS("6.0")]
}
