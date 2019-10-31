// swift-tools-version:5.0

import Foundation
import PackageDescription

// MARK: Helpers
let env = ProcessInfo.processInfo.environment

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
        .package(url: "https://github.com/Quick/Quick.git", from: "2.0.0"),
        // TODO: Use "8.0.2" until https://github.com/Quick/Nimble/issues/705 is fixed.
        .package(url: "https://github.com/Quick/Nimble.git", .exact("8.0.2")),
    ],
    targets: [
        .target(name: "CXLibc"),
        .target(name: "CXUtility"),
        .target(name: "CXNamespace"),
        .target(name: "CombineX", dependencies: ["CXLibc", "CXUtility", "CXNamespace"]),
        .target(name: "CXFoundation", dependencies: ["CXUtility", "CXNamespace", "CombineX"]),
        .target(name: "CXCompatible", dependencies: ["CXNamespace"]),
        .target(name: "CXShim", dependencies: [/* depends on combine implementation */]),
        .testTarget(name: "CombineXTests", dependencies: ["CXUtility", "CXShim", "Quick", "Nimble"]),
        .testTarget(name: "CXFoundationTests", dependencies: ["CXShim", "Quick", "Nimble"]),
        .testTarget(name: "CombineXFailingTests", dependencies: ["CXShim", "Quick", "Nimble"]),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)

// MARK: CombineX Experimental Features

/// Some of the implementations in CombineX are experimental.
struct CXExperimentalFeatures: OptionSet, CaseIterable {
    
    let rawValue: Int
    
    static let observableObject = CXExperimentalFeatures(rawValue: 1)
    
    static var allCases: [CXExperimentalFeatures] {
        return [.observableObject]
    }
    
    static var all: CXExperimentalFeatures {
        return .init(self.allCases)
    }
    
    var isEnabled: Bool {
        switch self {
        case .observableObject: return env["CX_EXPERIMENTAL_OBSERVABLE_OBJECT"] != nil
        default:                return false
        }
    }
    
    static var enabled: CXExperimentalFeatures {
        return .init(self.allCases.filter { $0.isEnabled })
    }
    
    func configure(_ package: Package) {
        guard let cxTarget = package.targets.first(where: { $0.name == "CombineX" }) else { return }
        
        // extra package dependencies
        package.dependencies.append(contentsOf: self.extraPackageDependencies)
        
        // extra swift settings
        cxTarget.swiftSettings.append(contentsOf: self.extraSwiftSettings)
        
        // extra target dependencies
        cxTarget.dependencies.append(contentsOf: self.extraTargetDependencies)
    }
    
    var extraPackageDependencies: [Package.Dependency] {
        var deps: [Package.Dependency] = []
        if contains(.observableObject) {
            deps += [.package(url: "https://github.com/wickwirew/Runtime", from: "2.0.0")]
        }
        return deps
    }
    
    var extraSwiftSettings: [SwiftSetting] {
        var settings: [SwiftSetting] = []
        if contains(.observableObject) {
            settings += [.define("EXPERIMENTAL_OBSERVABLE_OBJECT")]
        }
        return settings
    }
    
    var extraTargetDependencies: [Target.Dependency] {
        var deps: [Target.Dependency] = []
        if contains(.observableObject) {
            deps += ["Runtime"]
        }
        return deps
    }
}

let enabledCXExperimentalFeatures = CXExperimentalFeatures.enabled
enabledCXExperimentalFeatures.configure(package)

// MARK: Combine Implementations
enum CombineImplementation: CaseIterable {
    
    case combine, combineX, openCombine
    
    func configure(_ package: Package) {
        package.dependencies.append(contentsOf: self.extraPackageDependencies)
        
        guard let shimTarget = package.targets.first(where: { $0.name == "CXShim" }) else { return }
        
        shimTarget.dependencies = shimTargetDependencies
        shimTarget.swiftSettings.append(contentsOf: shimTargetSwiftSettings)
    }
    
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

let currentCombineImp = selectCombineImp()
currentCombineImp.configure(package)

// Pass the swift settings of current combine implementation and all experimental features to all test targets.
let testSwiftSettings = currentCombineImp.shimTargetSwiftSettings + CXExperimentalFeatures.all.extraSwiftSettings
package.targets.forEach {
    if $0.isTest {
        $0.swiftSettings.append(contentsOf: testSwiftSettings)
    }
}

// Travis does not yet support macOS 10.15, so we have to generate an iOS project to test against `Combine`.
if currentCombineImp == .combine && ProcessInfo.processInfo.environment["TRAVIS"] != nil {
    package.platforms = [.iOS("13.0")]
}
