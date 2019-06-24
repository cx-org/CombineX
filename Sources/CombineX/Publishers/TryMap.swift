extension Publisher {
    
    /// Transforms all elements from the upstream publisher with a provided error-throwing closure.
    ///
    /// If the `transform` closure throws an error, the publisher fails with the thrown error.
    /// - Parameter transform: A closure that takes one element as its parameter and returns a new element.
    /// - Returns: A publisher that uses the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    public func tryMap<T>(_ transform: @escaping (Self.Output) throws -> T) -> Publishers.TryMap<Self, T> {
        return Publishers.TryMap<Self, T>(upstream: self, transform: transform)
    }
}

extension Publishers.TryMap {
    
    public func map<T>(_ transform: @escaping (Output) -> T) -> Publishers.TryMap<Upstream, T> {
        let newTransform: (Upstream.Output) throws -> T = {
            do {
                let output = try self.transform($0)
                return transform(output)
            } catch {
                throw error
            }
        }
        return self.upstream.tryMap(newTransform)
    }
    
    public func tryMap<T>(_ transform: @escaping (Output) throws -> T) -> Publishers.TryMap<Upstream, T> {
        let newTransform: (Upstream.Output) throws -> T = {
            do {
                let output = try self.transform($0)
                return try transform(output)
            } catch {
                throw error
            }
        }
        return self.upstream.tryMap(newTransform)
    }
}

extension Publishers {
    
    /// A publisher that transforms all elements from the upstream publisher with a provided error-throwing closure.
    public struct TryMap<Upstream, Output> : Publisher where Upstream : Publisher {
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The error-throwing closure that transforms elements from the upstream publisher.
        public let transform: (Upstream.Output) throws -> Output
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, S.Failure == Publishers.TryMap<Upstream, Output>.Failure {
            let subscription = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(subscription)
        }
    }
}

extension Publishers.TryMap {
    
    private final class Inner<S>:
        Subscription,
        Subscriber,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure
    {
        
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
    
        typealias Pub = Publishers.TryMap<Upstream, Output>
        typealias Sub = S
        
        let state = Atomic<RelaySubscriptionState>(value: .waiting)
        
        var pub: Pub?
        var sub: Sub?
        
        init(pub: Pub, sub: Sub) {
            self.pub = pub
            self.sub = sub
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.state.subscription?.request(demand)
        }
        
        func cancel() {
            self.state.finishIfSubscribing()?.cancel()
            
            self.pub = nil
            self.sub = nil
        }
        
        func receive(subscription: Subscription) {
            if self.state.compareAndStore(expected: .waiting, newVaue: .subscribing(subscription)) {
                self.sub?.receive(subscription: self)
            } else {
                subscription.cancel()
            }
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            guard self.state.isSubscribing else {
                return .none
            }
            
            guard let pub = self.pub, let sub = self.sub else {
                return .none
            }
            
            do {
                return sub.receive(try pub.transform(input))
            } catch {
                if let subscription = self.state.finishIfSubscribing() {
                    subscription.cancel()
                    sub.receive(completion: .failure(error))
                }
                return .none
            }
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            if let subscription = self.state.finishIfSubscribing() {
                subscription.cancel()
                
                switch completion {
                case .finished:
                    self.sub?.receive(completion: .finished)
                case .failure(let error):
                    self.sub?.receive(completion: .failure(error))
                }
                
                self.pub = nil
                self.sub = nil
            }
        }
        
        var description: String {
            return "TryMap"
        }
        
        var debugDescription: String {
            return "TryMap"
        }
    }
}
