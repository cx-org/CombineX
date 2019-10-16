#if canImport(Foundation)

import Foundation

extension NSObject: CXCompatible, CXWrapper {}
extension JSONEncoder: CXCompatible, CXWrapper {}
extension JSONDecoder: CXCompatible, CXWrapper {}

extension CXWrappers {
    typealias NSObject = Foundation.NSObject
    typealias JSONEncoder = Foundation.JSONEncoder
    typealias JSONDecoder = Foundation.JSONDecoder
    typealias NotificationCenter = Foundation.NotificationCenter
    typealias OperationQueue = Foundation.OperationQueue
    typealias RunLoop = Foundation.RunLoop
    typealias Timer = Foundation.Timer
    typealias URLSession = Foundation.URLSession
}

#if !os(Linux)

extension PropertyListEncoder: CXCompatible, CXWrapper {}
extension PropertyListDecoder: CXCompatible, CXWrapper {}

extension CXWrappers {
    typealias PropertyListEncoder = Foundation.PropertyListEncoder
    typealias PropertyListDecoder = Foundation.PropertyListDecoder
}

#endif

#endif
