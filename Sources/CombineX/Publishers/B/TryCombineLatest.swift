extension Publisher {
    
    /// Subscribes to an additional publisher and invokes an error-throwing closure upon receiving output
    /// from either publisher.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still
    /// obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t
    /// `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size
    /// of 1 for each upstream, and holds the most recent value in each buffer.
    ///
    /// If the provided transform throws an error, the publisher fails with the error. `Failure` and
    /// `P.Failure` must both be `Swift.Error`.
    ///
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never
    /// publishes a value, this publisher never finishes.
    ///
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    ///
    /// - Parameters:
    ///   - other: Another publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and returns
    ///   a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this and another publisher.
    public func tryCombineLatest<P: Publisher, T>(
        _ other: P,
        _ transform: @escaping (Output, P.Output) throws -> T
    ) -> Publishers.TryCombineLatest<Self, P, T> where P.Failure == Error {
        return .init(self, other, transform: transform)
    }
}

extension Publishers {
    
    /// A publisher that receives and combines the latest elements from two publishers, using a throwing closure.
    public struct TryCombineLatest<A, B, Output>: Publisher where A: Publisher, B: Publisher, A.Failure == Error, B.Failure == Error {
        
        public typealias Failure = Error
        
        public let a: A
        
        public let b: B
        
        public let transform: (A.Output, B.Output) throws -> Output
        
        public init(_ a: A, _ b: B, transform: @escaping (A.Output, B.Output) throws -> Output) {
            self.a = a
            self.b = b
            self.transform = transform
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, S.Failure == Publishers.TryCombineLatest<A, B, Output>.Failure {
            self.a.combineLatest(self.b)
                .tryMap(self.transform)
                .receive(subscriber: subscriber)
        }
    }
}
