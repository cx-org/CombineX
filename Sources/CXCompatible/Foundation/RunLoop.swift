#if canImport(Foundation) && canImport(Combine)
import Foundation

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public typealias RunLoopCXWrapper = RunLoop.RunLoopCXWrapper

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineXCompatible where Self: RunLoop {
    
    public var cx: RunLoopCXWrapper {
        return self
    }
    
    public static var cx: RunLoopCXWrapper.Type {
        return RunLoopCXWrapper.self
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension RunLoop {
    
    public typealias RunLoopCXWrapper = RunLoop
}

#endif
