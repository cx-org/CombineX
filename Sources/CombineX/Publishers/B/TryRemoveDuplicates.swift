#if !COCOAPODS
import CXUtility
#endif

extension Publisher {
    
    /// Publishes only elements that don’t match the previous element, as evaluated by a provided error-throwing closure.
    /// - Parameter predicate: A closure to evaluate whether two elements are equivalent, for purposes of filtering. Return `true` from this closure to indicate that the second element is a duplicate of the first. If this closure throws an error, the publisher terminates with the thrown error.
    public func tryRemoveDuplicates(by predicate: @escaping (Output, Output) throws -> Bool) -> Publishers.TryRemoveDuplicates<Self> {
        return .init(upstream: self, predicate: predicate)
    }
}

extension Publishers {
    
    /// A publisher that publishes only elements that don’t match the previous element, as evaluated by a provided error-throwing closure.
    public struct TryRemoveDuplicates<Upstream: Publisher>: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Error
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// An error-throwing closure to evaluate whether two elements are equivalent, for purposes of filtering.
        public let predicate: (Upstream.Output, Upstream.Output) throws -> Bool
        
        /// Creates a publisher that publishes only elements that don’t match the previous element, as evaluated by a provided error-throwing closure.
        /// - Parameter upstream: The publisher from which this publisher receives elements.
        /// - Parameter predicate: An error-throwing closure to evaluate whether two elements are equivalent, for purposes of filtering. Return `true` from this closure to indicate that the second element is a duplicate of the first. If this closure throws an error, the publisher terminates with the thrown error.
        public init(upstream: Upstream, predicate: @escaping (Publishers.TryRemoveDuplicates<Upstream>.Output, Publishers.TryRemoveDuplicates<Upstream>.Output) throws -> Bool) {
            self.upstream = upstream
            self.predicate = predicate
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Output == S.Input, S.Failure == Publishers.TryRemoveDuplicates<Upstream>.Failure {
            let s = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(s)
        }
    }
}

extension Publishers.TryRemoveDuplicates {
    
    private final class Inner<S>: Subscription,
        Subscriber,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure {
        
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        typealias Pub = Publishers.TryRemoveDuplicates<Upstream>
        typealias Sub = S
        typealias Predicate = (Upstream.Output, Upstream.Output) throws -> Bool
        
        let lock = Lock()
        let predicate: Predicate
        let sub: Sub
        
        var previous: Output?
        var state = RelayState.waiting
        
        init(pub: Pub, sub: Sub) {
            self.predicate = pub.predicate
            self.sub = sub
        }
        
        deinit {
            lock.cleanupLock()
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.lock.withLockGet(self.state.subscription)?.request(demand)
        }
        
        func cancel() {
            self.lock.withLockGet(self.state.complete())?.cancel()
        }
        
        func receive(subscription: Subscription) {
            guard self.lock.withLockGet(self.state.relay(subscription)) else {
                subscription.cancel()
                return
            }
            
            self.sub.receive(subscription: self)
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            self.lock.lock()
            guard self.state.isRelaying else {
                self.lock.unlock()
                return .none
            }
            
            guard let previous = self.previous else {
                self.previous = input
                self.lock.unlock()
                return self.sub.receive(input)
            }

            do {
                if try self.predicate(previous, input) {
                    self.lock.unlock()
                    return .max(1)
                } else {
                    self.previous = input
                    self.lock.unlock()
                    return self.sub.receive(input)
                }
            } catch {
                let subscription = self.state.complete()
                self.lock.unlock()
                
                subscription?.cancel()
                self.sub.receive(completion: .failure(error))
                
                return .none
            }
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            self.complete(completion.mapError { $0 })
        }
        
        private func complete(_ completion: Subscribers.Completion<Error>) {
            guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                return
            }
            
            subscription.cancel()
            self.sub.receive(completion: completion.mapError { $0 })
        }
        
        var description: String {
            return "TryRemoveDuplicates"
        }
        
        var debugDescription: String {
            return "TryRemoveDuplicates"
        }
    }
}
