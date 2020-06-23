#if !COCOAPODS
import CXUtility
#endif

extension Publisher {
    
    /// Prefixes a `Publisher`'s output with the specified sequence.
    /// - Parameter elements: The elements to publish before this publisher’s elements.
    /// - Returns: A publisher that prefixes the specified elements prior to this publisher’s elements.
    public func prepend(_ elements: Output...) -> Publishers.Concatenate<Publishers.Sequence<[Output], Failure>, Self> {
        return .init(prefix: .init(sequence: elements), suffix: self)
    }
    
    /// Prefixes a `Publisher`'s output with the specified sequence.
    /// - Parameter elements: A sequence of elements to publish before this publisher’s elements.
    /// - Returns: A publisher that prefixes the sequence of elements prior to this publisher’s elements.
    public func prepend<S: Sequence>(_ elements: S) -> Publishers.Concatenate<Publishers.Sequence<S, Failure>, Self> where Output == S.Element {
        return .init(prefix: .init(sequence: elements), suffix: self)
    }
    
    /// Prefixes this publisher’s output with the elements emitted by the given publisher.
    ///
    /// The resulting publisher doesn’t emit any elements until the prefixing publisher finishes.
    /// - Parameter publisher: The prefixing publisher.
    /// - Returns: A publisher that prefixes the prefixing publisher’s elements prior to this publisher’s elements.
    public func prepend<P: Publisher>(_ publisher: P) -> Publishers.Concatenate<P, Self> where Failure == P.Failure, Output == P.Output {
        return .init(prefix: publisher, suffix: self)
    }
    
    /// Append a `Publisher`'s output with the specified sequence.
    public func append(_ elements: Output...) -> Publishers.Concatenate<Self, Publishers.Sequence<[Output], Failure>> {
        return .init(prefix: self, suffix: .init(sequence: elements))
    }
    
    /// Appends a `Publisher`'s output with the specified sequence.
    public func append<S: Sequence>(_ elements: S) -> Publishers.Concatenate<Self, Publishers.Sequence<S, Failure>> where Output == S.Element {
        return .init(prefix: self, suffix: .init(sequence: elements))
    }
    
    /// Appends this publisher’s output with the elements emitted by the given publisher.
    ///
    /// This operator produces no elements until this publisher finishes. It then produces this publisher’s elements, followed by the given publisher’s elements. If this publisher fails with an error, the prefixing publisher does not publish the provided publisher’s elements.
    /// - Parameter publisher: The appending publisher.
    /// - Returns: A publisher that appends the appending publisher’s elements after this publisher’s elements.
    public func append<P: Publisher>(_ publisher: P) -> Publishers.Concatenate<Self, P> where Failure == P.Failure, Output == P.Output {
        return .init(prefix: self, suffix: publisher)
    }
}

extension Publishers.Concatenate: Equatable where Prefix: Equatable, Suffix: Equatable {}

extension Publishers {
    
    /// A publisher that emits all of one publisher’s elements before those from another publisher.
    public struct Concatenate<Prefix, Suffix>: Publisher where Prefix: Publisher, Suffix: Publisher, Prefix.Failure == Suffix.Failure, Prefix.Output == Suffix.Output {
        
        public typealias Output = Suffix.Output
        
        public typealias Failure = Suffix.Failure
        
        /// The publisher to republish, in its entirety, before republishing elements from `suffix`.
        public let prefix: Prefix
        
        /// The publisher to republish only after `prefix` finishes.
        public let suffix: Suffix
        
        public init(prefix: Prefix, suffix: Suffix) {
            self.prefix = prefix
            self.suffix = suffix
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Suffix.Failure == S.Failure, Suffix.Output == S.Input {
            let s = Inner(pub: self, sub: subscriber)
            self.prefix.subscribe(s)
        }
    }
}

extension Publishers.Concatenate {
    
    private final class Inner<S>: Subscription,
        Subscriber,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Suffix.Output,
        S.Failure == Suffix.Failure {
        
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
        
        deinit {
            lock.cleanupLock()
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
