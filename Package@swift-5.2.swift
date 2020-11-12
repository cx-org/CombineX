// swift-tools-version:5.2

import PackageDescription

// MARK: - Package

let package = Package(
    name: "CombineX",
    platforms: [
        .macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v2),
    ],
    products: [
        // Open source implementation of Combine.
        .library(name: "CombineX", targets: ["CombineX", "CXFoundation"]),
        // Virtual Combine interface.
        .library(name: "CXShim", targets: ["CXShim"]),
        // Test infrastructure for Combine, built on CXShim.
        .library(name: "CXTest", targets: ["CXTest"])
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "3.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.0.0"),
        .package(url: "https://github.com/ddddxxx/Semver.git", .upToNextMinor(from: "0.2.1")),
    ],
    targets: [
        .target(name: "CXLibc"),
        .target(name: "CXUtility", dependencies: ["CXLibc"]),
        .target(name: "CXNamespace"),
        .target(name: "CombineX", dependencies: ["CXLibc", "CXUtility", "CXNamespace"]),
        .target(name: "CXFoundation", dependencies: ["CXUtility", "CXNamespace", "CombineX"]),
        .target(name: "CXCompatible", dependencies: ["CXNamespace"]),
        .target(name: "CXShim", dependencies: [/* depends on concrete combine implementation */]),
        .target(name: "CXTest", dependencies: ["CXUtility", "CXShim"]),
        .target(name: "CXTestUtility", dependencies: ["CXUtility", "CXTest", "Semver", "CXShim", "Nimble"]),
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
    
    var swiftSettings: [SwiftSetting] {
        switch self {
        case .combine:      return [.define("USE_COMBINE")]
        case .combineX:     return [.define("USE_COMBINEX")]
        case .openCombine:  return [.define("USE_OPEN_COMBINE")]
        }
    }
    
    var extraPackageDependencies: [Package.Dependency] {
        switch self {
        case .openCombine:  return [.package(url: "https://github.com/broadwaylamb/OpenCombine", .upToNextMinor(from: "0.8.0"))]
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
}

// MARK: - Helpers

extension ProcessInfo {
    
    var combineImplementation: CombineImplementation {
        return environment["CX_COMBINE_IMPLEMENTATION"].flatMap(CombineImplementation.init) ?? .default
    }
    
    var isCI: Bool {
        return (environment["CX_CONTINUOUS_INTEGRATION"] as NSString?)?.boolValue ?? false
    }
}

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

var combineImp = ProcessInfo.processInfo.combineImplementation
var isCI = ProcessInfo.processInfo.isCI

// uncommenet the following line to test against combine
//combineImp = .combine; isCI = true

package.dependencies.append(contentsOf: combineImp.extraPackageDependencies)

let shimTarget = package.targets.first(where: { $0.name == "CXShim" })!
shimTarget.dependencies = combineImp.shimTargetDependencies
shimTarget.swiftSettings.append(contentsOf: combineImp.swiftSettings)

let testUtilityTarget = package.targets.first(where: { $0.name == "CXTestUtility" })!
testUtilityTarget.swiftSettings.append(contentsOf: combineImp.swiftSettings)

if combineImp == .combine && isCI {
    package.platforms = [.macOS("10.15"), .iOS("13.0"), .tvOS("13.0"), .watchOS("6.0")]
} else {
    #if compiler(>=5.3)
    package.platforms = [.macOS(.v10_10), .iOS(.v9), .tvOS(.v9), .watchOS(.v2)]
    #endif
}
