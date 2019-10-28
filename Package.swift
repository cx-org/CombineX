// swift-tools-version:5.0

import Foundation
import PackageDescription

// MARK: Helpers
let env = ProcessInfo.processInfo.environment

// MARK: Combine Implementations
enum CombineImplementation: CaseIterable {
    
    case combine, combineX, openCombine
    
    ///     #if USE_COMBINEX
    ///        ...
    ///     #endif
    var swiftSettings: [SwiftSetting] {
        switch self {
        case .combine:      return [.define("USE_COMBINE")]
        case .combineX:     return [.define("USE_COMBINEX")]
        case .openCombine:  return [.define("USE_OPEN_COMBINE")]
        }
    }
    
    var shimTargetDependencies: [Target.Dependency] {
        switch self {
        case .combine:      return ["CXCompatible"]
        case .combineX:     return ["CombineX", "CXFoundation"]
        case .openCombine:  return ["OpenCombine", "OpenCombineDispatch"]
        }
    }
    
    var extraPackageDependencies: [Package.Dependency] {
        switch self {
        case .openCombine:  return [.package(url: "https://github.com/broadwaylamb/OpenCombine", .branch("master"))]
        default:            return []
        }
    }
}

func selectCombineImp() -> CombineImplementation {
    let imp = env["CX_IMPLEMENTATION"]?.lowercased()
    switch imp {
    case "combine":         return .combine
    case "combinex":        return .combineX
    case "opencombine":     return .openCombine
    default:
        #if canImport(Combine)
        return .combine
        #else
        return .combineX
        #endif
    }
}

// MARK: Experimental Features
struct ExperimentalFeatures: OptionSet, CaseIterable {
    
    let rawValue: Int
    
    static let observableObject = ExperimentalFeatures(rawValue: 1)
    
    static var allCases: [ExperimentalFeatures] {
        return [.observableObject]
    }
    
    var isEnabled: Bool {
        switch self {
        case .observableObject: return env["CX_EXPERIMENTAL_OBSERVABLE_OBJECT"] != nil
        default:                return false
        }
    }
    
    static var enabled: ExperimentalFeatures {
        return .init(self.allCases.filter { $0.isEnabled })
    }
    
    var swiftSettings: [SwiftSetting] {
        var settings: [SwiftSetting] = [.define("EXPERIMENTAL_PLACEHOLDER")]
        if contains(.observableObject) {
            settings += [.define("EXPERIMENTAL_OBSERVABLE_OBJECT")]
        }
        return settings
    }
    
    var extraPackageDependencies: [Package.Dependency] {
        var deps: [Package.Dependency] = []
        if contains(.observableObject) {
            deps += [.package(url: "https://github.com/wickwirew/Runtime", from: "2.0.0")]
        }
        return deps
    }
    
    var targetDependencies: [Target.Dependency] {
        var deps: [Target.Dependency] = []
        if contains(.observableObject) {
            deps += ["Runtime"]
        }
        return deps
    }
}

let combineImp = selectCombineImp()
let enabledExperimentalFeatures = ExperimentalFeatures.enabled

let testSwiftSettings = combineImp.swiftSettings + enabledExperimentalFeatures.swiftSettings

// MARK: - Package

let package = Package(
    name: "CombineX",
    platforms: [
        .macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v2),
    ],
    products: [
        .library(name: "CombineX", targets: ["CombineX", "CXFoundation"]),
        .library(name: "CXCompatible", targets: ["CXCompatible"]),
        .library(name: "CXShim", targets: ["CXShim"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "2.0.0"),
        // TODO: Use "8.0.2" until https://github.com/Quick/Nimble/issues/705 is fixed.
        .package(url: "https://github.com/Quick/Nimble.git", .exact("8.0.2")),
    ] + combineImp.extraPackageDependencies + enabledExperimentalFeatures.extraPackageDependencies,
    targets: [
        .target(name: "CXLibc"),
        .target(name: "CXUtility"),
        .target(name: "CXNamespace"),
        .target(name: "CombineX",
                dependencies: ["CXLibc", "CXUtility", "CXNamespace"] + enabledExperimentalFeatures.targetDependencies,
                swiftSettings: enabledExperimentalFeatures.swiftSettings),
        .target(name: "CXFoundation",
                dependencies: ["CXUtility", "CXNamespace", "CombineX"]),
        .target(name: "CXCompatible",
                dependencies: ["CXNamespace"]),
        .target(name: "CXShim",
                dependencies: combineImp.shimTargetDependencies,
                swiftSettings: combineImp.swiftSettings),
        .testTarget(name: "CombineXTests",
                    dependencies: ["CXUtility", "CXShim", "Quick", "Nimble"],
                    swiftSettings: testSwiftSettings),
        .testTarget(name: "CXFoundationTests",
                    dependencies: ["CXShim", "Quick", "Nimble"],
                    swiftSettings: testSwiftSettings),
    ],
    swiftLanguageVersions: [
        .v5, .version("5.1")
    ]
)

// MARK: CI
// Travis does not yet support macOS 10.15, so we have to generate an iOS project to test against `Combine`.
if combineImp == .combine && ProcessInfo.processInfo.environment["TRAVIS"] != nil {
    package.platforms = [.iOS("13.0")]
}
