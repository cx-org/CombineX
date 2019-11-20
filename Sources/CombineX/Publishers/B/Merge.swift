extension Publisher {
    
    /// Combines elements from this publisher with those from another publisher, delivering an interleaved sequence of elements.
    ///
    /// The merged publisher continues to emit elements until all upstream publishers finish. If an upstream publisher produces an error, the merged publisher fails with that error.
    /// - Parameter other: Another publisher.
    /// - Returns: A publisher that emits an event when either upstream publisher emits an event.
    public func merge<P: Publisher>(with other: P) -> Publishers.Merge<Self, P> where Failure == P.Failure, Output == P.Output {
        return .init(self, other)
    }
}

extension Publishers.Merge: Equatable where A: Equatable, B: Equatable {
    
    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A merging publisher to compare for equality.
    ///   - rhs: Another merging publisher to compare for equality..
    /// - Returns: `true` if the two merging - rhs: Another merging publisher to compare for equality.
    public static func == (lhs: Publishers.Merge<A, B>, rhs: Publishers.Merge<A, B>) -> Bool {
        return lhs.a == rhs.a && rhs.b == rhs.b
    }
}

extension Publishers {
    
    /// A publisher created by applying the merge function to two upstream publishers.
    public struct Merge<A, B>: Publisher where A: Publisher, B: Publisher, A.Failure == B.Failure, A.Output == B.Output {
        
        public typealias Output = A.Output
        
        public typealias Failure = A.Failure
        
        public let a: A
        
        public let b: B
        
        let pub: AnyPublisher<A.Output, A.Failure>
        
        public init(_ a: A, _ b: B) {
            self.a = a
            self.b = b
            
            self.pub = Publishers
                .Sequence(sequence: [a.eraseToAnyPublisher(), b.eraseToAnyPublisher()])
                .flatMap { $0 }
                .eraseToAnyPublisher()
        }
        
        public func receive<S: Subscriber>(subscriber: S) where B.Failure == S.Failure, B.Output == S.Input {
            self.pub.subscribe(subscriber)
        }
        
        public func merge<P: Publisher>(with other: P) -> Publishers.Merge3<A, B, P> where B.Failure == P.Failure, B.Output == P.Output {
            return .init(self.a, self.b, other)
        }
        
        public func merge<Z, Y>(with z: Z, _ y: Y) -> Publishers.Merge4<A, B, Z, Y> where Z: Publisher, Y: Publisher, B.Failure == Z.Failure, B.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output {
            return .init(self.a, self.b, z, y)
        }
        
        public func merge<Z, Y, X>(with z: Z, _ y: Y, _ x: X) -> Publishers.Merge5<A, B, Z, Y, X> where Z: Publisher, Y: Publisher, X: Publisher, B.Failure == Z.Failure, B.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output, Y.Failure == X.Failure, Y.Output == X.Output {
            return .init(self.a, self.b, z, y, x)
        }
        
        public func merge<Z, Y, X, W>(with z: Z, _ y: Y, _ x: X, _ w: W) -> Publishers.Merge6<A, B, Z, Y, X, W> where Z: Publisher, Y: Publisher, X: Publisher, W: Publisher, B.Failure == Z.Failure, B.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output, Y.Failure == X.Failure, Y.Output == X.Output, X.Failure == W.Failure, X.Output == W.Output {
            return .init(self.a, self.b, z, y, x, w)
        }
        
        public func merge<Z, Y, X, W, V>(with z: Z, _ y: Y, _ x: X, _ w: W, _ v: V) -> Publishers.Merge7<A, B, Z, Y, X, W, V> where Z: Publisher, Y: Publisher, X: Publisher, W: Publisher, V: Publisher, B.Failure == Z.Failure, B.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output, Y.Failure == X.Failure, Y.Output == X.Output, X.Failure == W.Failure, X.Output == W.Output, W.Failure == V.Failure, W.Output == V.Output {
            return .init(self.a, self.b, z, y, x, w, v)
        }
        
        public func merge<Z, Y, X, W, V, U>(with z: Z, _ y: Y, _ x: X, _ w: W, _ v: V, _ u: U) -> Publishers.Merge8<A, B, Z, Y, X, W, V, U> where Z: Publisher, Y: Publisher, X: Publisher, W: Publisher, V: Publisher, U: Publisher, B.Failure == Z.Failure, B.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output, Y.Failure == X.Failure, Y.Output == X.Output, X.Failure == W.Failure, X.Output == W.Output, W.Failure == V.Failure, W.Output == V.Output, V.Failure == U.Failure, V.Output == U.Output {
            return .init(self.a, self.b, z, y, x, w, v, u)
        }
    }
}
