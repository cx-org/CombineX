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

struct ExperimentalFeature: OptionSet, CaseIterable {
    
    let rawValue: Int
    
    static let observableObject = ExperimentalFeature(rawValue: 1)
    
    static var allCases: [ExperimentalFeature] {
        return [.observableObject]
    }
    
    var environmentFlag: String? {
        switch self {
        case .observableObject: return "COMBINEX_EXPERIMENTAL_OBSERVABLE_OBJECT"
        default: return nil
        }
    }
    
    var packageDependencies: [Package.Dependency] {
        var result: [Package.Dependency] = []
        if contains(.observableObject) {
            result += [.package(url: "https://github.com/wickwirew/Runtime", from: "2.0.0")]
        }
        return result
    }
    
    var targetDependencies: [Target.Dependency] {
        var result: [Target.Dependency] = []
        if contains(.observableObject) {
            result += ["Runtime"]
        }
        return result
    }
    
    var swiftSettings: [SwiftSetting]? {
        var result: [SwiftSetting] = []
        if contains(.observableObject) {
            result += [.define("EXPERIMENTAL_OBSERVABLE_OBJECT")]
        }
        return result.isEmpty ? nil : result
    }
}

func configExperimentalFeatures() -> ExperimentalFeature {
    let env = ProcessInfo.processInfo.environment
    let featureSet = ExperimentalFeature.allCases.filter { env.keys.contains($0.environmentFlag!) }
    return ExperimentalFeature(featureSet)
}

let combineImpl: CombineImplementation = selectCombineImpl()
let experimentalFeatures: ExperimentalFeature = configExperimentalFeatures()

let testSwiftSettings: [SwiftSetting] = [.define(combineImpl.swiftFlag)] + (experimentalFeatures.swiftSettings ?? [])

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
    ] + combineImpl.packageDependencies + experimentalFeatures.packageDependencies,
    targets: [
        .target(
            name: "CXUtility"),
        .target(
            name: "CombineX",
            dependencies: ["CXUtility"] + experimentalFeatures.targetDependencies,
            swiftSettings: experimentalFeatures.swiftSettings),
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
            dependencies: ["CXUtility", "CXShim", "Quick", "Nimble"],
            swiftSettings: testSwiftSettings),
        .testTarget(
            name: "CXFoundationTests",
            dependencies: ["CXShim", "Quick", "Nimble"],
            swiftSettings: testSwiftSettings),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)


/**
 for ci test
 */
if combineImpl == .combine && ProcessInfo.processInfo.environment["TRAVIS"] != nil {
    package.platforms = [.iOS("13.0")]
}
