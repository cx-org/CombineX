extension Optional: CXCompatible, CXWrapper {}
extension Result: CXCompatible, CXWrapper {}

extension CXWrappers {
    typealias Optional = Swift.Optional
    typealias Result = Swift.Result
    typealias Sequence = Swift.Sequence
}

extension Sequence {
    
    public var cx: Self {
        return self
    }
}
