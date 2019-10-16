// swift-tools-version:5.0

import Foundation
import PackageDescription

enum CombineImplementation: CaseIterable {
    
    case combine
    case combineX
    case openCombine
    
    var environmentFlag: String {
        switch self {
        case .combine: return "SWIFT_PACKAGE_USE_COMBINE"
        case .combineX: return "SWIFT_PACKAGE_USE_COMBINEX"
        case .openCombine: return "SWIFT_PACKAGE_USE_OPEN_COMBINE"
        }
    }
    
    var packageDependencies: [Package.Dependency] {
        switch self {
        case .combine, .combineX:
            return []
        case .openCombine:
            return [
                .package(url: "https://github.com/broadwaylamb/OpenCombine", .branch("master")),
            ]
        }
    }
    
    var targetDependencies: [Target.Dependency] {
        switch self {
        case .combine:
            return ["CXCompatible"]
        case .combineX:
            return ["CombineX", "CXFoundation"]
        case .openCombine:
            return ["OpenCombine", "OpenCombineDispatch"]
        }
    }
    
    var swiftFlag: String {
        switch self {
        case .combine: return "USE_COMBINE"
        case .combineX: return "USE_COMBINEX"
        case .openCombine: return "USE_OPEN_COMBINE"
        }
    }
}

func selectCombineImpl() -> CombineImplementation {
    #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    let defaultCombineImpl = CombineImplementation.combine
    #else
    let defaultCombineImpl = CombineImplementation.combineX
    #endif
    
    let env = ProcessInfo.processInfo.environment
    return CombineImplementation.allCases.first { impl in
        env[impl.environmentFlag] != nil
    } ?? defaultCombineImpl
}

let combineImpl: CombineImplementation = selectCombineImpl()

// MARK: - Package

let package = Package(
    name: "CombineX",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v8),
        .tvOS(.v9),
        .watchOS(.v2),
    ],
    products: [
        .library(
            name: "CombineX",
            targets: ["CombineX", "CXFoundation"]),
        .library(
            name: "CXCompatible",
            targets: ["CXCompatible"]),
        .library(
            name: "CXShim",
            targets: ["CXShim"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "2.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),
    ] + combineImpl.packageDependencies,
    targets: [
        .target(
            name: "CXUtility"),
        .target(
            name: "CombineX",
            dependencies: ["CXUtility"]),
        .target(
            name: "CXFoundation",
            dependencies: ["CXUtility", "CombineX"]),
        .target(
            name: "CXCompatible",
            dependencies: []),
        .target(
            name: "CXShim",
            dependencies: combineImpl.targetDependencies,
            swiftSettings: [.define(combineImpl.swiftFlag)]),
        
        // MARK: Tests
        .testTarget(
            name: "CombineXTests",
            dependencies: ["CXUtility", "CXShim", "Quick", "Nimble"]),
        .testTarget(
            name: "CXFoundationTests",
            dependencies: ["CXShim", "Quick", "Nimble"]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
