#if !COCOAPODS
import CXNamespace
#endif

extension Optional: CXSelfWrapping {}
extension Result: CXSelfWrapping {}

extension CXWrappers {
    public typealias Optional = Swift.Optional
    public typealias Result = Swift.Result
    public typealias Sequence = Swift.Sequence
}

extension Sequence {
    
    public var cx: Self {
        return self
    }
}
