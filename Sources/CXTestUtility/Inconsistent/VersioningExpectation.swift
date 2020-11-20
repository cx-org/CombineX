import Foundation
import Quick
import Nimble
import Semver

public extension Expectation {
    
    func to(_ predicate: Predicate<T>, minimalVersion: XcodeVersion, description: String? = nil) {
        toVersioning([minimalVersion: predicate], description: description)
    }
    
    func toVersioning(_ predicates: [XcodeVersion: Predicate<T>], description: String? = nil) {
        precondition(!predicates.isEmpty)
        let versions = predicates.keys.sorted(by: >)
        #if USE_COMBINE
        let osVersion = ProcessInfo.processInfo.operatingSystemSemanticVersion
        guard let targetVersion = versions.first(where: { osVersion >= $0.systemVersion }) else {
            // no available predicate for current system version
            // should we fail here?
            return
        }
        #else
        let targetVersion = versions.first!
        #endif
        let predicate = predicates[targetVersion]!
        to(predicate, description: description)
    }
}

/// Only test Combine with minimal system version shipping with specified Xcode.
///
/// This doesn't affect CombineX tests.
public func context(minimalVersion: XcodeVersion, closure: () -> Void) {
    let description = "tests requires Combine with minimal system version shipping with Xcode \(minimalVersion.version)"
    #if USE_COMBINE
    let enabled = ProcessInfo.processInfo.operatingSystemSemanticVersion > minimalVersion.systemVersion
    #else
    let enabled = true
    #endif
    context(description, flags: ["pending": !enabled], closure: closure)
}

// assume combine change its behaviour with xcode release, along with system update.
public enum XcodeVersion: Equatable, Hashable, Comparable {
    
    case v11_0
    case v11_1
    case v11_2
    case v11_3
    case v11_4
    case v11_5
    case v11_6
    case v11_7
    // let‘s forget about the chaotic period of Xcode 12.0 and skip to Xcode 12.2
    public static let v12_0 = XcodeVersion.v12_2
    case v12_2
    
    #if canImport(Darwin)
    var systemVersion: Semver {
        #if os(macOS)
        return macOSVersion
        #elseif os(iOS)
        return iOSVersion
        #elseif os(tvOS)
        return tvOSVersion
        #elseif os(watchOS)
        return watchOSVersion
        #endif
    }
    #endif
    
    var macOSVersion: Semver {
        switch self {
        case .v11_0: return "10.15.0"
        case .v11_1: return "10.15.0"
        case .v11_2: return "10.15.1"
        case .v11_3: return "10.15.2"
        case .v11_4: return "10.15.4"
        case .v11_5: return "10.15.5"
        case .v11_6: return "10.15.6"
        case .v11_7: return "10.15.6"
        case .v12_2: return "11.0.0" // actually 11.0.1
        }
    }
    
    var iOSVersion: Semver {
        switch self {
        case .v11_0: return "13.0.0"
        case .v11_1: return "13.1.0"
        case .v11_2: return "13.2.0"
        case .v11_3: return "13.3.0"
        case .v11_4: return "13.4.0"
        case .v11_5: return "13.5.0"
        case .v11_6: return "13.6.0"
        case .v11_7: return "13.7.0"
        case .v12_2: return "14.0.0" // actually 14.2.0
        }
    }
    
    var tvOSVersion: Semver {
        switch self {
        case .v11_0: return "13.0.0"
        case .v11_1: return "13.0.0"
        case .v11_2: return "13.2.0"
        case .v11_3: return "13.3.0"
        case .v11_4: return "13.4.0"
        case .v11_5: return "13.4.6"
        case .v11_6: return "13.4.8"
        case .v11_7: return "13.4.8"
        case .v12_2: return "14.0.0" // actually 14.2.0
        }
    }
    
    var watchOSVersion: Semver {
        switch self {
        case .v11_0: return "6.0.0"
        case .v11_1: return "6.0.0"
        case .v11_2: return "6.1.0"
        case .v11_3: return "6.1.1"
        case .v11_4: return "6.2.0"
        case .v11_5: return "6.2.6"
        case .v11_6: return "6.2.8"
        case .v11_7: return "6.2.8"
        case .v12_2: return "7.0.0" // actually 7.1.0
        }
    }
    
    var version: Semver {
        switch self {
        case .v11_0: return "11.0.0"
        case .v11_1: return "11.1.0"
        case .v11_2: return "11.2.0"
        case .v11_3: return "11.3.0"
        case .v11_4: return "11.4.0"
        case .v11_5: return "11.5.0"
        case .v11_6: return "11.6.0"
        case .v11_7: return "11.7.0"
        case .v12_2: return "12.2.0"
        }
    }
    
    public static func < (lhs: XcodeVersion, rhs: XcodeVersion) -> Bool {
        return lhs.version < rhs.version
    }
}
