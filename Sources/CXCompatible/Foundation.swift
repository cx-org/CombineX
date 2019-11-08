#if canImport(Foundation)

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

#if !COCOAPODS
import CXNamespace
#endif

extension NSObject: CXSelfWrapping {}
extension JSONEncoder: CXSelfWrapping {}
extension JSONDecoder: CXSelfWrapping {}

extension CXWrappers {
    public typealias NSObject = Foundation.NSObject
    public typealias JSONEncoder = Foundation.JSONEncoder
    public typealias JSONDecoder = Foundation.JSONDecoder
    public typealias NotificationCenter = Foundation.NotificationCenter
    public typealias OperationQueue = Foundation.OperationQueue
    public typealias RunLoop = Foundation.RunLoop
    public typealias Timer = Foundation.Timer
    #if canImport(FoundationNetworking)
    public typealias URLSession = FoundationNetworking.URLSession
    #else
    public typealias URLSession = Foundation.URLSession
    #endif
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

extension PropertyListEncoder: CXSelfWrapping {}
extension PropertyListDecoder: CXSelfWrapping {}

extension CXWrappers {
    public typealias PropertyListEncoder = Foundation.PropertyListEncoder
    public typealias PropertyListDecoder = Foundation.PropertyListDecoder
}

#endif

#endif
