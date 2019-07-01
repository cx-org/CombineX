extension Publisher {
    
    /// Only publishes the last element of a stream that satisfies a error-throwing predicate closure, after the stream finishes.
    ///
    /// If the predicate closure throws, the publisher fails with the thrown error.
    /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether to publish the element.
    /// - Returns: A publisher that only publishes the last element satisfying the given predicate.
    public func tryLast(where predicate: @escaping (Self.Output) throws -> Bool) -> Publishers.TryLastWhere<Self> {
        return .init(upstream: self, predicate: predicate)
    }
}

extension Publishers {
    
    /// A publisher that only publishes the last element of a stream that satisfies a error-throwing predicate closure, once the stream finishes.
    public struct TryLastWhere<Upstream> : Publisher where Upstream : Publisher {
        
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The error-throwing closure that determines whether to publish an element.
        public let predicate: (Upstream.Output) throws -> Bool
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Output == S.Input, S.Failure == Publishers.TryLastWhere<Upstream>.Failure {
            let subscription = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(subscription)
        }
    }
}

extension Publishers.TryLastWhere {
    
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
        
        typealias Pub = Publishers.TryLastWhere<Upstream>
        typealias Sub = S
        
        let lock = Lock()
        
        var state: RelayState = .waiting
        var last: Input?
        
        var pub: Pub?
        var sub: Sub?
        
        init(pub: Pub, sub: Sub) {
            self.pub = pub
            self.sub = sub
        }
        
        func request(_ demand: Subscribers.Demand) {
            precondition(demand > 0)
            self.lock.lock()
            let subscription = self.state.subscription
            self.lock.unlock()
            subscription?.request(.unlimited)
        }
        
        func cancel() {
            self.lock.lock()
            let subscription = self.state.finishIfRelaying()
            self.lock.unlock()
            
            subscription?.cancel()
            
            self.pub = nil
            self.sub = nil
        }
        
        func receive(subscription: Subscription) {
            self.lock.lock()
            switch self.state {
            case .waiting:
                self.state = .relaying(subscription)
                self.lock.unlock()
                self.sub?.receive(subscription: self)
            default:
                self.lock.unlock()
                subscription.cancel()
            }
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            self.lock.lock()
            
            guard self.state.isRelaying else {
                self.lock.unlock()
                return .none
            }
            
            guard let predicate = self.pub?.predicate else {
                self.lock.unlock()
                return .none
            }
            
            do {
                if try predicate(input) {
                    self.last = input
                }
                self.lock.unlock()
            } catch {
                let subscription = self.state.finishIfRelaying()
                self.lock.unlock()
                
                subscription?.cancel()
                self.sub?.receive(completion: .failure(error))
            }
            
            return .none
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            self.lock.lock()
            
            if let subscription = self.state.finishIfRelaying() {
                self.lock.unlock()
                
                subscription.cancel()
                switch completion {
                case .failure(let error):
                    self.sub?.receive(completion: .failure(error))
                case .finished:
                    if let last = self.last {
                        _ = self.sub?.receive(last)
                    }
                    self.sub?.receive(completion: .finished)
                }
                
                self.pub = nil
                self.sub = nil
            } else {
                self.lock.unlock()
            }
        }
        
        var description: String {
            return "TryLastWhere"
        }
        
        var debugDescription: String {
            return "TryLastWhere"
        }
    }
}
