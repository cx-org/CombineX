// swift-tools-version:5.0

import Foundation
import PackageDescription

let env = ProcessInfo.processInfo.environment

// MARK: Package
let package = Package(
    name: "CombineX",
    platforms: [
        .macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v2),
    ],
    products: [
        .library(name: "CombineX", targets: ["CombineX", "CXFoundation"]),
        .library(name: "CXShim", targets: ["CXShim"]),
    ],
    dependencies: [
        .package(url: "https://github.com/wickwirew/Runtime", from: "2.0.0"),
        .package(url: "https://github.com/Quick/Quick", from: "2.0.0"),
        // TODO: Use "8.0.2" until https://github.com/Quick/Nimble/issues/705 is fixed.
        .package(url: "https://github.com/Quick/Nimble", .exact("8.0.2")),
    ],
    targets: [
        .target(name: "CXLibc"),
        .target(name: "CXUtility"),
        .target(name: "CXNamespace"),
        .target(name: "CombineX", dependencies: ["CXLibc", "CXUtility", "CXNamespace", "Runtime"]),
        .target(name: "CXFoundation", dependencies: ["CXUtility", "CXNamespace", "CombineX"]),
        .target(name: "CXCompatible", dependencies: ["CXNamespace"]),
        .target(name: "CXShim", dependencies: [/* depends on combine implementation */]),
        .target(name: "CXTestUtility", dependencies: ["CXUtility", "CXShim", "Nimble"]),
        .testTarget(name: "CombineXTests", dependencies: ["CXTestUtility", "CXUtility", "CXShim", "Quick", "Nimble"]),
        .testTarget(name: "CXFoundationTests", dependencies: ["CXShim", "Quick", "Nimble"]),
        .testTarget(name: "CXInconsistentTests", dependencies: ["CXTestUtility", "CXUtility", "CXShim", "Quick", "Nimble"]),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)

// MARK: Helpers
extension Optional where Wrapped: RangeReplaceableCollection {
    
    mutating func append(contentsOf newElements: [Wrapped.Element]) {
        if newElements.isEmpty { return }
        
        if let wrapped = self {
            self = wrapped + newElements
        } else {
            self = .init(newElements)
        }
    }
}

// MARK: Combine Implementations
enum CombineImplementation {
    
    case combine, combineX, openCombine

    var extraPackageDependencies: [Package.Dependency] {
        switch self {
        case .openCombine:  return [.package(url: "https://github.com/broadwaylamb/OpenCombine", .branch("master"))]
        default:            return []
        }
    }
    
    var shimTargetDependencies: [Target.Dependency] {
        switch self {
        case .combine:      return ["CXCompatible"]
        case .combineX:     return ["CombineX", "CXFoundation"]
        case .openCombine:  return ["OpenCombine", "OpenCombineDispatch"]
        }
    }
    
    var shimTargetSwiftSettings: [SwiftSetting] {
        switch self {
        case .combine:      return [.define("USE_COMBINE")]
        case .combineX:     return [.define("USE_COMBINEX")]
        case .openCombine:  return [.define("USE_OPEN_COMBINE")]
        }
    }
}

func configure(_ package: Package, with imp: CombineImplementation) {
    package.dependencies.append(contentsOf: imp.extraPackageDependencies)
    
    guard let shimTarget = package.targets.first(where: { $0.name == "CXShim" }) else { return }
    
    shimTarget.dependencies = imp.shimTargetDependencies
    shimTarget.swiftSettings.append(contentsOf: imp.shimTargetSwiftSettings)
    
    // Pass the swift settings of current combine implementation to all test targets.
    package.targets
        .filter { $0.isTest}
        .forEach {
            $0.swiftSettings.append(contentsOf: imp.shimTargetSwiftSettings)
        }
}

func selectCombineImp() -> CombineImplementation {
    let key = "CX_COMBINE_IMPLEMENTATION"
    // CombineX -> combinex
    // OPEN_COMBINE -> opencombine
    let imp = env[key]?.lowercased().filter { $0.isLetter }
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

let currentCombineImp = selectCombineImp()
configure(package, with: currentCombineImp)

// Travis does not yet support macOS 10.15, so we have to generate an iOS project to test against `Combine`.
if currentCombineImp == .combine && ProcessInfo.processInfo.environment["TRAVIS"] != nil {
    package.platforms = [.iOS("13.0")]
}

