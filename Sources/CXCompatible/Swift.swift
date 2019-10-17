extension Optional: CXWrappable, CXWrapper {}
extension Result: CXWrappable, CXWrapper {}

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
