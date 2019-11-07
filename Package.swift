// swift-tools-version:5.0

import PackageDescription

// MARK: - Package

let package = Package(
    name: "CombineX",
    platforms: [
        .macOS("10.15"), .iOS(.v8), .tvOS(.v9), .watchOS(.v2),
    ],
    products: [
        .library(name: "CombineX", targets: ["CombineX", "CXFoundation"]),
        .library(name: "CXBridge", targets: ["CXBridge"]),
        .library(name: "CXShim", targets: ["CXShim"]),
    ],
    dependencies: [
        .package(url: "https://github.com/wickwirew/Runtime.git", from: "2.0.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "2.0.0"),
        // TODO: Use "8.0.2" until https://github.com/Quick/Nimble/issues/705 is fixed.
        .package(url: "https://github.com/Quick/Nimble.git", .exact("8.0.2")),
    ],
    targets: [
        .target(name: "CXLibc"),
        .target(name: "CXUtility"),
        .target(name: "CXNamespace"),
        .target(name: "CombineX", dependencies: ["CXLibc", "CXUtility", "CXNamespace", "Runtime"]),
        .target(name: "CXFoundation", dependencies: ["CXUtility", "CXNamespace", "CombineX"]),
        .target(name: "CXCompatible", dependencies: ["CXNamespace"]),
        .target(name: "CXBridge", dependencies: ["CXNamespace", "CombineX", "Runtime"]),
        .target(name: "CXShim", dependencies: [/* depends on combine implementation */]),
        .target(name: "CXTestUtility", dependencies: ["CXUtility", "CXShim", "Nimble"]),
        .testTarget(name: "CombineXTests", dependencies: ["CXTestUtility", "CXUtility", "CXShim", "Quick", "Nimble"]),
        .testTarget(name: "CXFoundationTests", dependencies: ["CXTestUtility", "CXShim", "Quick", "Nimble"]),
        .testTarget(name: "CXInconsistentTests", dependencies: ["CXTestUtility", "CXUtility", "CXShim", "Quick", "Nimble"]),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)

// MARK: - Combine Implementations

enum CombineImplementation {
    
    case combine
    case combineX
    case openCombine
    
    static var `default`: CombineImplementation {
        #if canImport(Combine)
        return .combine
        #else
        return .combineX
        #endif
    }
    
    init?(_ description: String) {
        let desc = description.lowercased().filter { $0.isLetter }
        switch desc {
        case "combine":     self = .combine
        case "combinex":    self = .combineX
        case "opencombine": self = .openCombine
        default:            return nil
        }
    }

    var extraPackageDependencies: [Package.Dependency] {
        switch self {
        case .openCombine:  return [.package(url: "https://github.com/broadwaylamb/OpenCombine", .exact("0.5.0"))]
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
    
    var swiftSettings: [SwiftSetting] {
        switch self {
        case .combine:      return [.define("USE_COMBINE")]
        case .combineX:     return [.define("USE_COMBINEX")]
        case .openCombine:  return [.define("USE_OPEN_COMBINE")]
        }
    }
}

// MARK: - Helpers

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

// MARK: - Config Package

import Foundation

let env = ProcessInfo.processInfo.environment
let impkey = "CX_COMBINE_IMPLEMENTATION"
let isCIKey = "CX_CONTINUOUS_INTEGRATION"

var combineImp = env[impkey].flatMap(CombineImplementation.init) ?? .default
var isCI = env[isCIKey] != nil

// uncommenet the following two lines if you want to test against combine
//combineImp = .combine; isCI = true

package.dependencies.append(contentsOf: combineImp.extraPackageDependencies)

let shimTarget = package.targets.first(where: { $0.name == "CXShim" })!
shimTarget.dependencies = combineImp.shimTargetDependencies
shimTarget.swiftSettings.append(contentsOf: combineImp.swiftSettings)

for target in package.targets where target.isTest || target.name == "CXTestUtility" {
    target.swiftSettings.append(contentsOf: combineImp.swiftSettings)
}

if combineImp == .combine && isCI {
    package.platforms = [.macOS("10.15"), .iOS("13.0"), .tvOS("13.0"), .watchOS("6.0")]
}
