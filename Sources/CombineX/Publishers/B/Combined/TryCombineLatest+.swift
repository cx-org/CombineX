extension Publisher {
    
    /// Subscribes to two additional publishers and invokes an error-throwing closure upon receiving output
    /// from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still
    /// obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t
    /// `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size
    ///  of 1 for each upstream, and holds the most recent value in each buffer.
    ///
    /// If the provided transform throws an error, the publisher fails with the error. `Failure`,
    /// `P.Failure`, and `Q.Failure` must all be `Swift.Error`.
    ///
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never
    /// publishes a value, this publisher never finishes.
    ///
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    ///
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a
    ///   new value to publish.
    /// - Returns: A publisher that receives and combines elements from this publisher and two other publishers.
    public func tryCombineLatest<P, Q, T>(_ publisher1: P, _ publisher2: Q, _ transform: @escaping (Output, P.Output, Q.Output) throws -> T) -> Publishers.TryCombineLatest3<Self, P, Q, T> where P: Publisher, Q: Publisher, P.Failure == Error, Q.Failure == Error {
        return .init(self, publisher1, publisher2, transform: transform)
    }
    
    /// Subscribes to three additional publishers and invokes an error-throwing closure upon receiving
    /// output from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still
    /// obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t
    /// `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size
    /// of 1 for each upstream, and holds the most recent value in each buffer.
    ///
    /// If the provided transform throws an error, the publisher fails with the error. `Failure`,
    /// `P.Failure`, `Q.Failure`, and `R.Failure` must all be `Swift.Error`.
    ///
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never
    /// publishes a value, this publisher never finishes.
    ///
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    ///   - publisher3: A fourth publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a
    ///   new value to publish.
    /// - Returns: A publisher that receives and combines elements from this publisher and three other publishers.
    public func tryCombineLatest<P, Q, R, T>(_ publisher1: P, _ publisher2: Q, _ publisher3: R, _ transform: @escaping (Output, P.Output, Q.Output, R.Output) throws -> T) -> Publishers.TryCombineLatest4<Self, P, Q, R, T> where P: Publisher, Q: Publisher, R: Publisher, P.Failure == Error, Q.Failure == Error, R.Failure == Error {
        return .init(self, publisher1, publisher2, publisher3, transform: transform)
    }
}

extension Publishers {
    
    /// A publisher that receives and combines the latest elements from three publishers, using a throwing closure.
    public struct TryCombineLatest3<A, B, C, Output>: Publisher where A: Publisher, B: Publisher, C: Publisher, A.Failure == Error, B.Failure == Error, C.Failure == Error {
        
        public typealias Failure = Error
        
        public let a: A
        
        public let b: B
        
        public let c: C
        
        public let transform: (A.Output, B.Output, C.Output) throws -> Output
        
        public init(_ a: A, _ b: B, _ c: C, transform: @escaping (A.Output, B.Output, C.Output) throws -> Output) {
            self.a = a
            self.b = b
            self.c = c
            self.transform = transform
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, S.Failure == Publishers.TryCombineLatest3<A, B, C, Output>.Failure {
            self.a
                .combineLatest(self.b)
                .combineLatest(self.c)
                .tryMap {
                    try self.transform($0.0, $0.1, $1)
                }
                .receive(subscriber: subscriber)
        }
    }
    
    /// A publisher that receives and combines the latest elements from four publishers, using a throwing closure.
    public struct TryCombineLatest4<A, B, C, D, Output>: Publisher where A: Publisher, B: Publisher, C: Publisher, D: Publisher, A.Failure == Error, B.Failure == Error, C.Failure == Error, D.Failure == Error {
        
        public typealias Failure = Error
        
        public let a: A
        
        public let b: B
        
        public let c: C
        
        public let d: D
        
        public let transform: (A.Output, B.Output, C.Output, D.Output) throws -> Output
        
        public init(_ a: A, _ b: B, _ c: C, _ d: D, transform: @escaping (A.Output, B.Output, C.Output, D.Output) throws -> Output) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
            self.transform = transform
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, S.Failure == Publishers.TryCombineLatest4<A, B, C, D, Output>.Failure {
            self.a
                .combineLatest(self.b)
                .combineLatest(self.c)
                .combineLatest(self.d)
                .tryMap {
                    try self.transform($0.0.0, $0.0.1, $0.1, $1)
                }
                .receive(subscriber: subscriber)
        }
    }
}
