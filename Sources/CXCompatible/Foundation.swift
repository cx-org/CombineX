#if canImport(Foundation)
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension NSObject: CXWrappable, CXWrapper {}
extension JSONEncoder: CXWrappable, CXWrapper {}
extension JSONDecoder: CXWrappable, CXWrapper {}

extension CXWrappers {
    public typealias NSObject = Foundation.NSObject
    public typealias JSONEncoder = Foundation.JSONEncoder
    public typealias JSONDecoder = Foundation.JSONDecoder
    public typealias NotificationCenter = Foundation.NotificationCenter
    public typealias OperationQueue = Foundation.OperationQueue
    public typealias RunLoop = Foundation.RunLoop
    public typealias Timer = Foundation.Timer
    public typealias URLSession = Foundation.URLSession
}

#if !os(Linux)

extension PropertyListEncoder: CXWrappable, CXWrapper {}
extension PropertyListDecoder: CXWrappable, CXWrapper {}

extension CXWrappers {
    public typealias PropertyListEncoder = Foundation.PropertyListEncoder
    public typealias PropertyListDecoder = Foundation.PropertyListDecoder
}

#endif

#endif
