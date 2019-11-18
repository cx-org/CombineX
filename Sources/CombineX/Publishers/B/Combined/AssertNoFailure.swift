extension Publisher {
    
    /// Raises a fatal error when its upstream publisher fails, and otherwise republishes all received input.
    ///
    /// Use this function for internal sanity checks that are active during testing but do not impact performance of shipping code.
    ///
    /// - Parameters:
    ///   - prefix: A string used at the beginning of the fatal error message.
    ///   - file: A filename used in the error message. This defaults to `#file`.
    ///   - line: A line number used in the error message. This defaults to `#line`.
    /// - Returns: A publisher that raises a fatal error when its upstream publisher fails.
    public func assertNoFailure(_ prefix: String = "", file: StaticString = #file, line: UInt = #line) -> Publishers.AssertNoFailure<Self> {
        return .init(upstream: self, prefix: prefix, file: file, line: line)
    }
}

extension Publishers {
    
    /// A publisher that raises a fatal error upon receiving any failure, and otherwise republishes all received input.
    ///
    /// Use this function for internal sanity checks that are active during testing but do not impact performance of shipping code.
    public struct AssertNoFailure<Upstream: Publisher>: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Never
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The string used at the beginning of the fatal error message.
        public let prefix: String
        
        /// The filename used in the error message.
        public let file: StaticString
        
        /// The line number used in the error message.
        public let line: UInt
        
        public init(upstream: Upstream, prefix: String, file: StaticString, line: UInt) {
            self.upstream = upstream
            self.prefix = prefix
            self.file = file
            self.line = line
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Output == S.Input, S.Failure == Publishers.AssertNoFailure<Upstream>.Failure {
            self.upstream
                .mapError {
                    fatalError(self.prefix + ": Assert no failure, but got \($0)", file: self.file, line: self.line)
                }
                .receive(subscriber: subscriber)
        }
    }
}
