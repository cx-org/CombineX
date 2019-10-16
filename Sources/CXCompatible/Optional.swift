#if canImport(Combine)
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol OptionalProtocol {
    
    associatedtype Wrapped
    
    var optional: Wrapped? {
        set get
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Optional: OptionalProtocol {

    public var optional: Wrapped? {
        get { return self }
        set { self = newValue }
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Optional {
    
    public enum CX {
        
        public typealias Publisher = Optional.Publisher
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Optional: CombineXCompatible { }

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineXWrapper where Base: OptionalProtocol { }

#endif
