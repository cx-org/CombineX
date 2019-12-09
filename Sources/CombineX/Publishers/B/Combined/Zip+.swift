extension Publisher {
    
    /// Combine elements from two other publishers and deliver groups of elements as tuples.
    ///
    /// The returned publisher waits until all three publishers have emitted an event, then delivers the oldest
    /// unconsumed event from each publisher as a tuple to the subscriber.
    ///
    /// For example, if publisher `P1` emits elements `a` and `b`, and publisher `P2` emits elements
    /// `c` and `d`, and publisher `P3` emits the event `e`, the zip publisher emits the tuple
    /// `(a, c, e)`. It won’t emit a tuple with elements `b` or `d` until `P3` emits another event.
    ///
    /// If any upstream publisher finishes successfuly or fails with an error, the zipped publisher does the same.
    ///
    /// - Parameters:
    ///   - publisher1: A second publisher.
    ///   - publisher2: A third publisher.
    /// - Returns: A publisher that emits groups of elements from the upstream publishers as tuples.
    public func zip<P, Q>(_ publisher1: P, _ publisher2: Q) -> Publishers.Zip3<Self, P, Q> where P: Publisher, Q: Publisher, Failure == P.Failure, P.Failure == Q.Failure {
        return .init(self, publisher1, publisher2)
    }
    
    /// Combine elements from two other publishers and deliver a transformed output.
    ///
    /// The returned publisher waits until all three publishers have emitted an event, then delivers the oldest
    /// unconsumed event from each publisher as a tuple to the subscriber.
    ///
    /// For example, if publisher `P1` emits elements `a` and `b`, and publisher `P2` emits elements
    /// `c` and `d`, and publisher `P3` emits the event `e`, the zip publisher emits the tuple
    /// `(a, c, e)`. It won’t emit a tuple with elements `b` or `d` until `P3` emits another event.
    ///
    /// If any upstream publisher finishes successfuly or fails with an error, the zipped publisher does the same.
    ///
    /// - Parameters:
    ///   - publisher1: A second publisher.
    ///   - publisher2: A third publisher.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that emits groups of elements from the upstream publishers as tuples.
    public func zip<P, Q, T>(_ publisher1: P, _ publisher2: Q, _ transform: @escaping (Output, P.Output, Q.Output) -> T) -> Publishers.Map<Publishers.Zip3<Self, P, Q>, T> where P: Publisher, Q: Publisher, Failure == P.Failure, P.Failure == Q.Failure {
        return self.zip(publisher1, publisher2).map(transform)
    }
    
    /// Combine elements from three other publishers and deliver groups of elements as tuples.
    ///
    /// The returned publisher waits until all four publishers have emitted an event, then delivers the oldest
    /// unconsumed event from each publisher as a tuple to the subscriber.
    ///
    /// For example, if publisher `P1` emits elements `a` and `b`, and publisher `P2` emits elements
    /// `c` and `d`, and publisher `P3` emits the elements `e` and `f`, and publisher `P4` emits the
    /// event `g`, the zip publisher emits the tuple `(a, c, e, g)`. It won’t emit a tuple with elements
    /// `b`, `d`, or `f` until `P4` emits another event.
    ///
    /// If any upstream publisher finishes successfuly or fails with an error, the zipped publisher does the same.
    ///
    /// - Parameters:
    ///   - publisher1: A second publisher.
    ///   - publisher2: A third publisher.
    ///   - publisher3: A fourth publisher.
    /// - Returns: A publisher that emits groups of elements from the upstream publishers as tuples.
    public func zip<P, Q, R>(_ publisher1: P, _ publisher2: Q, _ publisher3: R) -> Publishers.Zip4<Self, P, Q, R> where P: Publisher, Q: Publisher, R: Publisher, Failure == P.Failure, P.Failure == Q.Failure, Q.Failure == R.Failure {
        return .init(self, publisher1, publisher2, publisher3)
    }
    
    /// Combine elements from three other publishers and deliver a transformed output.
    ///
    /// The returned publisher waits until all four publishers have emitted an event, then delivers the oldest
    /// unconsumed event from each publisher as a tuple to the subscriber.
    ///
    /// For example, if publisher `P1` emits elements `a` and `b`, and publisher `P2` emits elements
    /// `c` and `d`, and publisher `P3` emits the elements `e` and `f`, and publisher `P4` emits the
    /// event `g`, the zip publisher emits the tuple `(a, c, e, g)`. It won’t emit a tuple with elements
    /// `b`, `d`, or `f` until `P4` emits another event.
    ///
    /// If any upstream publisher finishes successfuly or fails with an error, the zipped publisher does the same.
    ///
    /// - Parameters:
    ///   - publisher1: A second publisher.
    ///   - publisher2: A third publisher.
    ///   - publisher3: A fourth publisher.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a
    ///   new value to publish.
    /// - Returns: A publisher that emits groups of elements from the upstream publishers as tuples.
    public func zip<P, Q, R, T>(_ publisher1: P, _ publisher2: Q, _ publisher3: R, _ transform: @escaping (Output, P.Output, Q.Output, R.Output) -> T) -> Publishers.Map<Publishers.Zip4<Self, P, Q, R>, T> where P: Publisher, Q: Publisher, R: Publisher, Failure == P.Failure, P.Failure == Q.Failure, Q.Failure == R.Failure {
        return self.zip(publisher1, publisher2, publisher3).map(transform)
    }
}

/// Returns a Boolean value that indicates whether two publishers are equivalent.
///
/// - Parameters:
///   - lhs: A zip publisher to compare for equality.
///   - rhs: Another zip publisher to compare for equality.
/// - Returns: `true` if the corresponding upstream publishers of each zip publisher are equal, `false` otherwise.
extension Publishers.Zip3: Equatable where A: Equatable, B: Equatable, C: Equatable {}

/// Returns a Boolean value that indicates whether two publishers are equivalent.
///
/// - Parameters:
///   - lhs: A zip publisher to compare for equality.
///   - rhs: Another zip publisher to compare for equality.
/// - Returns: `true` if the corresponding upstream publishers of each zip publisher are equal, `false` otherwise.
extension Publishers.Zip4: Equatable where A: Equatable, B: Equatable, C: Equatable, D: Equatable {}

extension Publishers {
    
    /// A publisher created by applying the zip function to three upstream publishers.
    public struct Zip3<A, B, C>: Publisher where A: Publisher, B: Publisher, C: Publisher, A.Failure == B.Failure, B.Failure == C.Failure {
        
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
            self.a.zip(self.b).zip(self.c)
                .map {
                    ($0.0, $0.1, $1)
                }
                .receive(subscriber: subscriber)
        }
    }
    
    /// A publisher created by applying the zip function to four upstream publishers.
    public struct Zip4<A, B, C, D>: Publisher where A: Publisher, B: Publisher, C: Publisher, D: Publisher, A.Failure == B.Failure, B.Failure == C.Failure, C.Failure == D.Failure {
        
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
            self.a.zip(self.b).zip(self.c).zip(self.d)
                .map {
                    ($0.0.0, $0.0.1, $0.1, $1)
                }
                .receive(subscriber: subscriber)
        }
    }
}
