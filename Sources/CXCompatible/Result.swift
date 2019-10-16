#if canImport(Combine)
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol ResultProtocol {
    
    associatedtype Success
    associatedtype Failure: Error
    
    var result: Result<Success, Failure> {
        set get
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Result: ResultProtocol {
    
    public var result: Result {
        get { return self }
        set { self = newValue }
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Result {
    
    public enum CX {
        
        public typealias Publisher = Result.Publisher
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Result: CombineXCompatible { }

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineXWrapper where Base: ResultProtocol {
    
    public var publisher: Result<Base.Success, Base.Failure>.CX.Publisher {
        return .init(self.base.result)
    }
}

#endif
