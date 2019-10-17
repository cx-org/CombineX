extension Optional: CXWrappable, CXWrapper {}
extension Result: CXWrappable, CXWrapper {}

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
