#if canImport(Foundation) && canImport(Combine)
import Foundation

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public typealias OperationQueueCXWrapper = OperationQueue.OperationQueueCXWrapper

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineXCompatible where Self: OperationQueue {
    
    public var cx: OperationQueueCXWrapper {
        return self
    }
    
    public static var cx: OperationQueueCXWrapper.Type {
        return OperationQueueCXWrapper.self
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension OperationQueue {
    
    public typealias OperationQueueCXWrapper = OperationQueue
}

#endif
