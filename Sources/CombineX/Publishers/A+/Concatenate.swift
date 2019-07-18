extension Publisher {
    
    /// Prefixes a `Publisher`'s output with the specified sequence.
    /// - Parameter elements: The elements to publish before this publisher’s elements.
    /// - Returns: A publisher that prefixes the specified elements prior to this publisher’s elements.
    public func prepend(_ elements: Self.Output...) -> Publishers.Concatenate<Publishers.Sequence<[Self.Output], Self.Failure>, Self> {
        return .init(prefix: .init(sequence: elements), suffix: self)
    }
    
    /// Prefixes a `Publisher`'s output with the specified sequence.
    /// - Parameter elements: A sequence of elements to publish before this publisher’s elements.
    /// - Returns: A publisher that prefixes the sequence of elements prior to this publisher’s elements.
    public func prepend<S>(_ elements: S) -> Publishers.Concatenate<Publishers.Sequence<S, Self.Failure>, Self> where S : Sequence, Self.Output == S.Element {
        return .init(prefix: .init(sequence: elements), suffix: self)
    }
    
    /// Prefixes this publisher’s output with the elements emitted by the given publisher.
    ///
    /// The resulting publisher doesn’t emit any elements until the prefixing publisher finishes.
    /// - Parameter publisher: The prefixing publisher.
    /// - Returns: A publisher that prefixes the prefixing publisher’s elements prior to this publisher’s elements.
    public func prepend<P>(_ publisher: P) -> Publishers.Concatenate<P, Self> where P : Publisher, Self.Failure == P.Failure, Self.Output == P.Output {
        return .init(prefix: publisher, suffix: self)
    }
    
    /// Append a `Publisher`'s output with the specified sequence.
    public func append(_ elements: Self.Output...) -> Publishers.Concatenate<Self, Publishers.Sequence<[Self.Output], Self.Failure>> {
        return .init(prefix: self, suffix: .init(sequence: elements))
    }
    
    /// Appends a `Publisher`'s output with the specified sequence.
    public func append<S>(_ elements: S) -> Publishers.Concatenate<Self, Publishers.Sequence<S, Self.Failure>> where S : Sequence, Self.Output == S.Element {
        return .init(prefix: self, suffix: .init(sequence: elements))
    }
    
    /// Appends this publisher’s output with the elements emitted by the given publisher.
    ///
    /// This operator produces no elements until this publisher finishes. It then produces this publisher’s elements, followed by the given publisher’s elements. If this publisher fails with an error, the prefixing publisher does not publish the provided publisher’s elements.
    /// - Parameter publisher: The appending publisher.
    /// - Returns: A publisher that appends the appending publisher’s elements after this publisher’s elements.
    public func append<P>(_ publisher: P) -> Publishers.Concatenate<Self, P> where P : Publisher, Self.Failure == P.Failure, Self.Output == P.Output {
        return .init(prefix: self, suffix: publisher)
    }
}

extension Publishers.Concatenate : Equatable where Prefix : Equatable, Suffix : Equatable {
    
    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A concatenate publisher to compare for equality.
    ///   - rhs: Another concatenate publisher to compare for equality.
    /// - Returns: `true` if the two publishers’ prefix and suffix properties are equal, `false` otherwise.
    public static func == (lhs: Publishers.Concatenate<Prefix, Suffix>, rhs: Publishers.Concatenate<Prefix, Suffix>) -> Bool {
        return lhs.prefix == rhs.prefix && lhs.suffix == rhs.suffix
    }
}

extension Publishers {
    
    /// A publisher that emits all of one publisher’s elements before those from another publisher.
    public struct Concatenate<Prefix, Suffix> : Publisher where Prefix : Publisher, Suffix : Publisher, Prefix.Failure == Suffix.Failure, Prefix.Output == Suffix.Output {
        
        /// The kind of values published by this publisher.
        public typealias Output = Suffix.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Suffix.Failure
        
        /// The publisher to republish, in its entirety, before republishing elements from `suffix`.
        public let prefix: Prefix
        
        /// The publisher to republish only after `prefix` finishes.
        public let suffix: Suffix
        
        public init(prefix: Prefix, suffix: Suffix) {
            self.prefix = prefix
            self.suffix = suffix
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Suffix.Failure == S.Failure, Suffix.Output == S.Input {
            let s = Inner(pub: self, sub: subscriber)
            self.prefix.subscribe(s)
        }
    }
}

extension Publishers.Concatenate {
    
    private final class Inner<S>:
        Subscription,
        Subscriber,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Suffix.Output,
        S.Failure == Suffix.Failure
    {
        
        typealias Input = Prefix.Output
        typealias Failure = Prefix.Failure
        
        typealias Pub = Publishers.Concatenate<Prefix, Suffix>
        typealias Sub = S
        
        enum Stage {
            case prefix
            case halftime
            case suffix
        }
        
        let lock = Lock()
        let sub: Sub
        
        var state: RelayState = .waiting
        var demand: Subscribers.Demand = .none
        
        var stage = Stage.prefix
        var suffix: Suffix?
        
        init(pub: Pub, sub: Sub) {
            self.suffix = pub.suffix
            self.sub = sub
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.lock.lock()
            guard let subscription = self.state.subscription else {
                self.lock.unlock()
                return
            }
            
            let old = self.demand
            self.demand += demand
            let new = self.demand
            
            self.lock.unlock()
            
            if old == 0 {
                subscription.request(new)
            }
        }
        
        func cancel() {
            self.lock.withLockGet(self.state.complete())?.cancel()
        }
        
        func receive(subscription: Subscription) {
            self.lock.lock()
            switch self.state {
            case .waiting:
                self.state = .relaying(subscription)
                self.lock.unlock()
                self.sub.receive(subscription: self)
            case .relaying:
                switch self.stage {
                case .prefix, .suffix:
                    self.lock.unlock()
                    subscription.cancel()
                case .halftime:
                    self.stage = .suffix
                    self.state = .relaying(subscription)
                    let demand = self.demand
                    self.lock.unlock()
                    
                    subscription.request(demand)
                }
            case .completed:
                self.lock.unlock()
                subscription.cancel()
            }
        }
        
        func receive(_ input: Prefix.Output) -> Subscribers.Demand {
            self.lock.lock()
            guard self.state.isRelaying else {
                self.lock.unlock()
                return .none
            }
            
            self.demand -= 1
            self.lock.unlock()

            let new = self.sub.receive(input)
            self.lock.withLock {
                self.demand += new
            }
            return new
        }
        
        func receive(completion: Subscribers.Completion<Prefix.Failure>) {
            switch completion {
            case .failure:
                guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                    return
                }
                
                subscription.cancel()
                self.sub.receive(completion: completion)
            case .finished:
                self.lock.lock()
                guard self.state.isRelaying else {
                    self.lock.unlock()
                    return
                }
                switch self.stage {
                case .prefix:
                    self.stage = .halftime
                    let suffix = self.suffix
                    self.suffix = nil
                    self.lock.unlock()
                    
                    suffix?.subscribe(self)
                case .suffix:
                    let subscription = self.state.complete()!
                    self.lock.unlock()
                    
                    subscription.cancel()
                    self.sub.receive(completion: completion)
                case .halftime:
                    self.lock.unlock()
                }
            }
        }
        
        var description: String {
            return "Concatenate"
        }
        
        var debugDescription: String {
            return "Concatenate"
        }
    }
}
