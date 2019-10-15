#if canImport(Foundation) && canImport(Combine)
import Dispatch

#if os(Linux)
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension DispatchQueue: CombineXCompatible { }

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension DispatchQueue {
    
    public enum CX { }
}
#endif

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public typealias DispatchQueueCXWrapper = DispatchQueue.DispatchQueueCXWrapper

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineXCompatible where Self: DispatchQueue {
    
    public var cx: DispatchQueueCXWrapper {
        return self
    }
    
    public static var cx: DispatchQueueCXWrapper.Type {
        return DispatchQueueCXWrapper.self
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension DispatchQueue {
    
    public typealias DispatchQueueCXWrapper = DispatchQueue
}

#endif
