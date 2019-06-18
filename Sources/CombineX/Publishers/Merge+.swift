extension Publishers {
    
    /// A publisher created by applying the merge function to three upstream publishers.
    public struct Merge3<A, B, C> : Publisher where A : Publisher, B : Publisher, C : Publisher, A.Failure == B.Failure, A.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output {
        
        /// The kind of values published by this publisher.
        public typealias Output = A.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure
        
        public let a: A
        
        public let b: B
        
        public let c: C
        
        let pub: AnyPublisher<A.Output, A.Failure>
        
        public init(_ a: A, _ b: B, _ c: C) {
            self.a = a
            self.b = b
            self.c = c
            
            self.pub = Publishers
                .Sequence(sequence: [
                    a.eraseToAnyPublisher(),
                    b.eraseToAnyPublisher(),
                    c.eraseToAnyPublisher()
                ])
                .flatMap { $0 }
                .eraseToAnyPublisher()
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, C.Failure == S.Failure, C.Output == S.Input {
            self.pub.subscribe(subscriber)
        }
        
        public func merge<P>(with other: P) -> Publishers.Merge4<A, B, C, P> where P : Publisher, C.Failure == P.Failure, C.Output == P.Output {
            return .init(a, b, c, other)
        }
        
        public func merge<Z, Y>(with z: Z, _ y: Y) -> Publishers.Merge5<A, B, C, Z, Y> where Z : Publisher, Y : Publisher, C.Failure == Z.Failure, C.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output {
            return .init(a, b, c, z, y)
        }
        
        public func merge<Z, Y, X>(with z: Z, _ y: Y, _ x: X) -> Publishers.Merge6<A, B, C, Z, Y, X> where Z : Publisher, Y : Publisher, X : Publisher, C.Failure == Z.Failure, C.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output, Y.Failure == X.Failure, Y.Output == X.Output {
            return .init(a, b, c, z, y, x)
        }
        
        public func merge<Z, Y, X, W>(with z: Z, _ y: Y, _ x: X, _ w: W) -> Publishers.Merge7<A, B, C, Z, Y, X, W> where Z : Publisher, Y : Publisher, X : Publisher, W : Publisher, C.Failure == Z.Failure, C.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output, Y.Failure == X.Failure, Y.Output == X.Output, X.Failure == W.Failure, X.Output == W.Output {
            return .init(a, b, c, z, y, x, w)
        }
        
        public func merge<Z, Y, X, W, V>(with z: Z, _ y: Y, _ x: X, _ w: W, _ v: V) -> Publishers.Merge8<A, B, C, Z, Y, X, W, V> where Z : Publisher, Y : Publisher, X : Publisher, W : Publisher, V : Publisher, C.Failure == Z.Failure, C.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output, Y.Failure == X.Failure, Y.Output == X.Output, X.Failure == W.Failure, X.Output == W.Output, W.Failure == V.Failure, W.Output == V.Output {
            return .init(a, b, c, z, y, x, w, v)
        }
    }
    
    /// A publisher created by applying the merge function to four upstream publishers.
    public struct Merge4<A, B, C, D> : Publisher where A : Publisher, B : Publisher, C : Publisher, D : Publisher, A.Failure == B.Failure, A.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output, C.Failure == D.Failure, C.Output == D.Output {
        
        /// The kind of values published by this publisher.
        public typealias Output = A.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure
        
        public let a: A
        
        public let b: B
        
        public let c: C
        
        public let d: D
        
        let pub: AnyPublisher<A.Output, A.Failure>
        
        public init(_ a: A, _ b: B, _ c: C, _ d: D) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
            
            self.pub = Publishers
                .Sequence(sequence: [
                    a.eraseToAnyPublisher(),
                    b.eraseToAnyPublisher(),
                    c.eraseToAnyPublisher(),
                    d.eraseToAnyPublisher()
                    ])
                .flatMap { $0 }
                .eraseToAnyPublisher()
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, D.Failure == S.Failure, D.Output == S.Input {
            self.pub.subscribe(subscriber)
        }
        
        public func merge<P>(with other: P) -> Publishers.Merge5<A, B, C, D, P> where P : Publisher, D.Failure == P.Failure, D.Output == P.Output {
            return .init(a, b, c, d, other)
        }
        
        public func merge<Z, Y>(with z: Z, _ y: Y) -> Publishers.Merge6<A, B, C, D, Z, Y> where Z : Publisher, Y : Publisher, D.Failure == Z.Failure, D.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output {
            return .init(a, b, c, d, z, y)
        }
        
        public func merge<Z, Y, X>(with z: Z, _ y: Y, _ x: X) -> Publishers.Merge7<A, B, C, D, Z, Y, X> where Z : Publisher, Y : Publisher, X : Publisher, D.Failure == Z.Failure, D.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output, Y.Failure == X.Failure, Y.Output == X.Output {
            return .init(a, b, c, d, z, y, x)
        }
        
        public func merge<Z, Y, X, W>(with z: Z, _ y: Y, _ x: X, _ w: W) -> Publishers.Merge8<A, B, C, D, Z, Y, X, W> where Z : Publisher, Y : Publisher, X : Publisher, W : Publisher, D.Failure == Z.Failure, D.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output, Y.Failure == X.Failure, Y.Output == X.Output, X.Failure == W.Failure, X.Output == W.Output {
            return .init(a, b, c, d, z, y, x, w)
        }
    }
    
    /// A publisher created by applying the merge function to five upstream publishers.
    public struct Merge5<A, B, C, D, E> : Publisher where A : Publisher, B : Publisher, C : Publisher, D : Publisher, E : Publisher, A.Failure == B.Failure, A.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output, C.Failure == D.Failure, C.Output == D.Output, D.Failure == E.Failure, D.Output == E.Output {
        
        /// The kind of values published by this publisher.
        public typealias Output = A.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure
        
        public let a: A
        
        public let b: B
        
        public let c: C
        
        public let d: D
        
        public let e: E
        
        let pub: AnyPublisher<A.Output, A.Failure>
        
        public init(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
            self.e = e
            
            self.pub = Publishers
                .Sequence(sequence: [
                    a.eraseToAnyPublisher(),
                    b.eraseToAnyPublisher(),
                    c.eraseToAnyPublisher(),
                    d.eraseToAnyPublisher(),
                    e.eraseToAnyPublisher()
                    ])
                .flatMap { $0 }
                .eraseToAnyPublisher()
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, E.Failure == S.Failure, E.Output == S.Input {
            self.pub.subscribe(subscriber)
        }
        
        public func merge<P>(with other: P) -> Publishers.Merge6<A, B, C, D, E, P> where P : Publisher, E.Failure == P.Failure, E.Output == P.Output {
            return .init(a, b, c, d, e, other)
        }
        
        public func merge<Z, Y>(with z: Z, _ y: Y) -> Publishers.Merge7<A, B, C, D, E, Z, Y> where Z : Publisher, Y : Publisher, E.Failure == Z.Failure, E.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output {
            return .init(a, b, c, d, e, z, y)
        }
        
        public func merge<Z, Y, X>(with z: Z, _ y: Y, _ x: X) -> Publishers.Merge8<A, B, C, D, E, Z, Y, X> where Z : Publisher, Y : Publisher, X : Publisher, E.Failure == Z.Failure, E.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output, Y.Failure == X.Failure, Y.Output == X.Output {
            return .init(a, b, c, d, e, z, y, x)
        }
    }
    
    /// A publisher created by applying the merge function to six upstream publishers.
    public struct Merge6<A, B, C, D, E, F> : Publisher where A : Publisher, B : Publisher, C : Publisher, D : Publisher, E : Publisher, F : Publisher, A.Failure == B.Failure, A.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output, C.Failure == D.Failure, C.Output == D.Output, D.Failure == E.Failure, D.Output == E.Output, E.Failure == F.Failure, E.Output == F.Output {
        
        /// The kind of values published by this publisher.
        public typealias Output = A.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure
        
        public let a: A
        
        public let b: B
        
        public let c: C
        
        public let d: D
        
        public let e: E
        
        public let f: F
        
        let pub: AnyPublisher<A.Output, A.Failure>
        
        public init(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
            self.e = e
            self.f = f
            
            self.pub = Publishers
                .Sequence(sequence: [
                    a.eraseToAnyPublisher(),
                    b.eraseToAnyPublisher(),
                    c.eraseToAnyPublisher(),
                    d.eraseToAnyPublisher(),
                    e.eraseToAnyPublisher(),
                    f.eraseToAnyPublisher()
                    ])
                .flatMap { $0 }
                .eraseToAnyPublisher()
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, F.Failure == S.Failure, F.Output == S.Input {
            self.pub.subscribe(subscriber)
        }
        
        public func merge<P>(with other: P) -> Publishers.Merge7<A, B, C, D, E, F, P> where P : Publisher, F.Failure == P.Failure, F.Output == P.Output {
            return .init(a, b, c, d, e, f, other)
        }
        
        public func merge<Z, Y>(with z: Z, _ y: Y) -> Publishers.Merge8<A, B, C, D, E, F, Z, Y> where Z : Publisher, Y : Publisher, F.Failure == Z.Failure, F.Output == Z.Output, Z.Failure == Y.Failure, Z.Output == Y.Output {
            return .init(a, b, c, d, e, f, z, y)
        }
    }
    
    /// A publisher created by applying the merge function to seven upstream publishers.
    public struct Merge7<A, B, C, D, E, F, G> : Publisher where A : Publisher, B : Publisher, C : Publisher, D : Publisher, E : Publisher, F : Publisher, G : Publisher, A.Failure == B.Failure, A.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output, C.Failure == D.Failure, C.Output == D.Output, D.Failure == E.Failure, D.Output == E.Output, E.Failure == F.Failure, E.Output == F.Output, F.Failure == G.Failure, F.Output == G.Output {
        
        /// The kind of values published by this publisher.
        public typealias Output = A.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure
        
        public let a: A
        
        public let b: B
        
        public let c: C
        
        public let d: D
        
        public let e: E
        
        public let f: F
        
        public let g: G
        
        let pub: AnyPublisher<A.Output, A.Failure>
        
        public init(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
            self.e = e
            self.f = f
            self.g = g
            
            self.pub = Publishers
                .Sequence(sequence: [
                    a.eraseToAnyPublisher(),
                    b.eraseToAnyPublisher(),
                    c.eraseToAnyPublisher(),
                    d.eraseToAnyPublisher(),
                    e.eraseToAnyPublisher(),
                    f.eraseToAnyPublisher(),
                    g.eraseToAnyPublisher()
                    ])
                .flatMap { $0 }
                .eraseToAnyPublisher()
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, G.Failure == S.Failure, G.Output == S.Input {
            self.pub.subscribe(subscriber)
        }
        
        public func merge<P>(with other: P) -> Publishers.Merge8<A, B, C, D, E, F, G, P> where P : Publisher, G.Failure == P.Failure, G.Output == P.Output {
            return .init(a, b, c, d, e, f, g, other)
        }
    }
    
    /// A publisher created by applying the merge function to eight upstream publishers.
    public struct Merge8<A, B, C, D, E, F, G, H> : Publisher where A : Publisher, B : Publisher, C : Publisher, D : Publisher, E : Publisher, F : Publisher, G : Publisher, H : Publisher, A.Failure == B.Failure, A.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output, C.Failure == D.Failure, C.Output == D.Output, D.Failure == E.Failure, D.Output == E.Output, E.Failure == F.Failure, E.Output == F.Output, F.Failure == G.Failure, F.Output == G.Output, G.Failure == H.Failure, G.Output == H.Output {
        
        /// The kind of values published by this publisher.
        public typealias Output = A.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure
        
        public let a: A
        
        public let b: B
        
        public let c: C
        
        public let d: D
        
        public let e: E
        
        public let f: F
        
        public let g: G
        
        public let h: H
        
        let pub: AnyPublisher<A.Output, A.Failure>
        
        public init(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
            self.e = e
            self.f = f
            self.g = g
            self.h = h
            
            self.pub = Publishers
                .Sequence(sequence: [
                    a.eraseToAnyPublisher(),
                    b.eraseToAnyPublisher(),
                    c.eraseToAnyPublisher(),
                    d.eraseToAnyPublisher(),
                    e.eraseToAnyPublisher(),
                    f.eraseToAnyPublisher(),
                    g.eraseToAnyPublisher(),
                    h.eraseToAnyPublisher()
                    ])
                .flatMap { $0 }
                .eraseToAnyPublisher()
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, H.Failure == S.Failure, H.Output == S.Input {
            self.pub.subscribe(subscriber)
        }
    }
    
    public struct MergeMany<Upstream> : Publisher where Upstream : Publisher {
        
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        public let publishers: [Upstream]
        
        let pub: AnyPublisher<Upstream.Output, Upstream.Failure>
        
        public init(_ upstream: Upstream...) {
            self.publishers = upstream
         
            self.pub = Publishers
                .Sequence(sequence: upstream)
                .flatMap { $0 }
                .eraseToAnyPublisher()
        }
        
        public init<S>(_ upstream: S) where Upstream == S.Element, S : Swift.Sequence {
            self.publishers = Array(upstream)
            
            self.pub = Publishers
                .Sequence(sequence: upstream)
                .flatMap { $0 }
                .eraseToAnyPublisher()
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            
            self.pub.subscribe(subscriber)
        }
        
        public func merge(with other: Upstream) -> Publishers.MergeMany<Upstream> {
            return Publishers.MergeMany(Array(self.publishers) + [other])
        }
    }
}
