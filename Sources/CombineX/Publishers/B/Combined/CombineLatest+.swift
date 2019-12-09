extension Publisher {
    
    /// Subscribes to two additional publishers and publishes a tuple upon receiving output from any of the
    /// publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still
    /// obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t
    /// `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size
    /// of 1 for each upstream, and holds the most recent value in each buffer.
    ///
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never
    /// publishes a value, this publisher never finishes.
    ///
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    ///
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    /// - Returns: A publisher that receives and combines elements from this publisher and two other publishers.
    public func combineLatest<P, Q>(_ publisher1: P, _ publisher2: Q) -> Publishers.CombineLatest3<Self, P, Q> where P: Publisher, Q: Publisher, Failure == P.Failure, P.Failure == Q.Failure {
        return .init(self, publisher1, publisher2)
    }
    
    /// Subscribes to two additional publishers and invokes a closure upon receiving output from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still
    /// obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t
    /// `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size
    /// of 1 for each upstream, and holds the most recent value in each buffer.
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
    public func combineLatest<P, Q, T>(_ publisher1: P, _ publisher2: Q, _ transform: @escaping (Output, P.Output, Q.Output) -> T) -> Publishers.Map<Publishers.CombineLatest3<Self, P, Q>, T> where P: Publisher, Q: Publisher, Failure == P.Failure, P.Failure == Q.Failure {
        return self.combineLatest(publisher1, publisher2).map(transform)
    }
    
    /// Subscribes to three additional publishers and publishes a tuple upon receiving output from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still
    /// obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t
    /// `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size
    /// of 1 for each upstream, and holds the most recent value in each buffer.
    ///
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never
    /// publishes a value, this publisher never finishes.
    ///
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    ///
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    ///   - publisher3: A fourth publisher to combine with this one.
    /// - Returns: A publisher that receives and combines elements from this publisher and three other publishers.
    public func combineLatest<P, Q, R>(_ publisher1: P, _ publisher2: Q, _ publisher3: R) -> Publishers.CombineLatest4<Self, P, Q, R> where P: Publisher, Q: Publisher, R: Publisher, Failure == P.Failure, P.Failure == Q.Failure, Q.Failure == R.Failure {
        return .init(self, publisher1, publisher2, publisher3)
    }
    
    /// Subscribes to three additional publishers and invokes a closure upon receiving output from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still
    /// obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t
    /// `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size
    /// of 1 for each upstream, and holds the most recent value in each buffer.
    ///
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never
    /// publishes a value, this publisher never finishes.
    ///
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    ///
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    ///   - publisher3: A fourth publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a
    ///   new value to publish.
    /// - Returns: A publisher that receives and combines elements from this publisher and three other publishers.
    public func combineLatest<P, Q, R, T>(_ publisher1: P, _ publisher2: Q, _ publisher3: R, _ transform: @escaping (Output, P.Output, Q.Output, R.Output) -> T) -> Publishers.Map<Publishers.CombineLatest4<Self, P, Q, R>, T> where P: Publisher, Q: Publisher, R: Publisher, Failure == P.Failure, P.Failure == Q.Failure, Q.Failure == R.Failure {
        return self.combineLatest(publisher1, publisher2, publisher3).map(transform)
    }
}

/// Returns a Boolean value that indicates whether two publishers are equivalent.
///
/// - Parameters:
///   - lhs: A combineLatest publisher to compare for equality.
///   - rhs: Another combineLatest publisher to compare for equality.
/// - Returns: `true` if the corresponding upstream publishers of each combineLatest publisher are
/// equal, `false` otherwise.
extension Publishers.CombineLatest3: Equatable where A: Equatable, B: Equatable, C: Equatable {}

/// Returns a Boolean value that indicates whether two publishers are equivalent.
///
/// - Parameters:
///   - lhs: A combineLatest publisher to compare for equality.
///   - rhs: Another combineLatest publisher to compare for equality.
/// - Returns: `true` if the corresponding upstream publishers of each combineLatest publisher are
/// equal, `false` otherwise.
extension Publishers.CombineLatest4: Equatable where A: Equatable, B: Equatable, C: Equatable, D: Equatable {}

extension Publishers {
    
    /// A publisher that receives and combines the latest elements from three publishers.
    public struct CombineLatest3<A, B, C>: Publisher where A: Publisher, B: Publisher, C: Publisher, A.Failure == B.Failure, B.Failure == C.Failure {
        
        public typealias Output = (A.Output, B.Output, C.Output)
        
        public typealias Failure = A.Failure
        
        public let a: A
        
        public let b: B
        
        public let c: C
        
        public init(_ a: A, _ b: B, _ c: C) {
            self.a = a
            self.b = b
            self.c = c
        }
        
        public func receive<S: Subscriber>(subscriber: S) where C.Failure == S.Failure, S.Input == (A.Output, B.Output, C.Output) {
            self.a
                .combineLatest(self.b)
                .combineLatest(self.c)
                .map {
                    ($0.0, $0.1, $1)
                }
                .receive(subscriber: subscriber)
        }
    }
    
    /// A publisher that receives and combines the latest elements from four publishers.
    public struct CombineLatest4<A, B, C, D>: Publisher where A: Publisher, B: Publisher, C: Publisher, D: Publisher, A.Failure == B.Failure, B.Failure == C.Failure, C.Failure == D.Failure {
        
        public typealias Output = (A.Output, B.Output, C.Output, D.Output)
        
        public typealias Failure = A.Failure
        
        public let a: A
        
        public let b: B
        
        public let c: C
        
        public let d: D
        
        public init(_ a: A, _ b: B, _ c: C, _ d: D) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
        }
        
        public func receive<S: Subscriber>(subscriber: S) where D.Failure == S.Failure, S.Input == (A.Output, B.Output, C.Output, D.Output) {
            self.a
                .combineLatest(self.b)
                .combineLatest(self.c)
                .combineLatest(self.d)
                .map {
                    ($0.0.0, $0.0.1, $0.1, $1)
                }
                .receive(subscriber: subscriber)
        }
    }
}
