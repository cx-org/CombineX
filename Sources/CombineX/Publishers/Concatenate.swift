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
            let subscription = Inner(pub: self, sub: subscriber)
            
            let child = Inner<S>.Child(parent: subscription)
            self.prefix.subscribe(child)
        }
    }
}

extension Publishers.Concatenate {
    
    private final class Inner<S>:
        Subscription,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Suffix.Output,
        S.Failure == Suffix.Failure
    {
        
        typealias Pub = Publishers.Concatenate<Prefix, Suffix>
        typealias Sub = S
        
        let lock = Lock(recursive: true)

        var relayState: RelayState = .waiting
        var demand: Subscribers.Demand = .none
        
        var subscriptionCount = 0
        
        var pub: Pub?
        var sub: Sub?
        
        init(pub: Pub, sub: Sub) {
            self.pub = pub
            self.sub = sub
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.lock.lock()
            let subscription = self.relayState.subscription
            self.demand += demand
            self.lock.unlock()
            
            subscription?.request(demand)
        }
        
        func cancel() {
            self.lock.lock()
            self.relayState = .finished
            self.lock.unlock()
            
            self.pub = nil
            self.sub = nil
        }
        
        // MARK: Child
        func receive(subscription: Subscription) {
            self.lock.lock()
            self.subscriptionCount += 1
            switch self.relayState {
            case .waiting:
                self.relayState = .relaying(subscription)
                self.lock.unlock()
                self.sub?.receive(subscription: self)
            case .relaying:
                self.relayState = .relaying(subscription)
                self.lock.unlock()
                subscription.request(self.demand)
            default:
                self.lock.unlock()
            }
        }
        
        func receive(_ input: Suffix.Output) -> Subscribers.Demand {
            self.lock.lock()
            let demand = self.sub?.receive(input) ?? .none
            self.demand += demand
            self.lock.unlock()

            return demand
        }
        
        func receive(completion: Subscribers.Completion<Suffix.Failure>) {
            self.lock.lock()
            
            switch completion {
            case .failure:
                self.relayState = .finished
                self.lock.unlock()
                
                self.sub?.receive(completion: completion)
                
                self.pub = nil
                self.sub = nil
            case .finished:
                if self.subscriptionCount == 1 {
                    self.lock.unlock()
                    
                    if let suffix = self.pub?.suffix {
                        let child = Child(parent: self)
                        suffix.subscribe(child)
                    }
                } else {
                    self.relayState = .finished
                    self.lock.unlock()
                    
                    self.sub?.receive(completion: completion)
                    
                    self.pub = nil
                    self.sub = nil
                }
            }
        }
        
        var description: String {
            return "Concatenate"
        }
        
        var debugDescription: String {
            return "Concatenate"
        }
        
        final class Child: Subscriber {
            
            typealias Input = Suffix.Output
            typealias Failure = Suffix.Failure
            
            let subscription = Atomic<Subscription?>(value: nil)
            
            let parent: Inner
            init(parent: Inner) {
                self.parent = parent
            }
            
            func receive(subscription: Subscription) {
                if self.subscription.ifNilStore(subscription) {
                    self.parent.receive(subscription: subscription)
                    return
                }
                subscription.cancel()
            }
            
            func receive(_ input: Input) -> Subscribers.Demand {
                if self.subscription.isNil {
                    return .none
                }
                return self.parent.receive(input)
            }
            
            func receive(completion: Subscribers.Completion<Failure>) {
                if self.subscription.isNil {
                    return
                }
                return self.parent.receive(completion: completion)
            }
        }
    }
}
