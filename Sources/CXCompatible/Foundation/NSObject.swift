#if canImport(Foundation) && canImport(Combine)
import Foundation

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
open class AnyObjectCXWrapper<Base>: CombineXWrapper {
    public let base: Base
    required public init(_ base: Base) {
        self.base = base
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension NSObject: CombineXCompatible { }

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineXCompatible where Self: AnyObject {
    
    public var cx: AnyObjectCXWrapper<Self> {
        return .init(self)
    }
    
    public static var cx: AnyObjectCXWrapper<Self>.Type {
        return AnyObjectCXWrapper<Self>.self
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension NSObject {
    
    public enum CX { }
}

#if canImport(ObjectiveC)
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension NSObject.CX {
    
    public typealias KeyValueObservingPublisher = NSObject.KeyValueObservingPublisher
}
#endif

#endif
