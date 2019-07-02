extension Publisher {
    
    /// Calls an error-throwing closure with each received element and publishes any returned optional that has a value.
    ///
    /// If the closure throws an error, the publisher cancels the upstream and sends the thrown error to the downstream receiver as a `Failure`.
    /// - Parameter transform: an error-throwing closure that receives a value and returns an optional value.
    /// - Returns: A publisher that republishes all non-`nil` results of calling the transform closure.
    public func tryCompactMap<T>(_ transform: @escaping (Self.Output) throws -> T?) -> Publishers.TryCompactMap<Self, T> {
        return .init(upstream: self, transform: transform)
    }
}

extension Publishers.TryCompactMap {
    
    public func compactMap<T>(_ transform: @escaping (Output) throws -> T?) -> Publishers.TryCompactMap<Upstream, T> {
        let newTransform: (Upstream.Output) throws -> T? = {
            if let output = try self.transform($0) {
                return try transform(output)
            }
            return nil
        }
        
        return self.upstream.tryCompactMap(newTransform)
    }
}

extension Publishers {
    
    /// A publisher that republishes all non-`nil` results of calling an error-throwing closure with each received element.
    public struct TryCompactMap<Upstream, Output> : Publisher where Upstream : Publisher {
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// an error-throwing closure that receives values from the upstream publisher and returns optional values.
        ///
        /// If this closure throws an error, the publisher fails.
        public let transform: (Upstream.Output) throws -> Output?
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, S.Failure == Publishers.TryCompactMap<Upstream, Output>.Failure {
            let subscription = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(subscription)
        }
    }
}

extension Publishers.TryCompactMap {
    
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
        
        typealias Pub = Publishers.TryCompactMap<Upstream, Output>
        typealias Sub = S
        
        let lock = Lock()
        var state: RelayState = .waiting
        
        var pub: Pub?
        var sub: Sub?
        
        init(pub: Pub, sub: Sub) {
            self.pub = pub
            self.sub = sub
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.lock.lock()
            let subscription = self.state.subscription
            self.lock.unlock()
            
            subscription?.request(demand)
        }
        
        func cancel() {
            self.lock.lock()
            let subscription = self.state.finishIfRelaying()
            self.pub = nil
            self.sub = nil
            self.lock.unlock()
            
            subscription?.cancel()
        }
        
        func receive(subscription: Subscription) {
            self.lock.lock()
            
            guard self.state.isWaiting else {
                self.lock.unlock()
                
                subscription.cancel()
                return
            }
            
            self.state = .relaying(subscription)
            let sub = self.sub!
            
            self.lock.unlock()
            
            sub.receive(subscription: self)
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            self.lock.lock()
            
            guard self.state.isRelaying else {
                self.lock.unlock()
                return .none
            }
            
            let pub = self.pub!
            let sub = self.sub!
            
            self.lock.unlock()

            do {
                if let transformed = try pub.transform(input) {
                    return sub.receive(transformed)
                } else {
                    return .max(1)
                }
            } catch {
                self.complete(.failure(error))
                return .none
            }
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            self.complete(completion.mapError { $0 })
        }
        
        private func complete(_ completion: Subscribers.Completion<Error>) {
            self.lock.lock()
            guard let subscription = self.state.finishIfRelaying() else {
                self.lock.unlock()
                return
            }
            let sub = self.sub!
            self.lock.unlock()
            
            subscription.cancel()
            
            sub.receive(completion: completion.mapError { $0 })
            
            self.pub = nil
            self.sub = nil
        }
        
        var description: String {
            return "TryCompactMap"
        }
        
        var debugDescription: String {
            return "TryCompactMap"
        }
    }
}
