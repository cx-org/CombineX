
extension Publisher {
    
    /// Publishes a single Boolean value that indicates whether all received elements pass a given error-throwing predicate.
    ///
    /// When this publisher receives an element, it runs the predicate against the element. If the predicate returns `false`, the publisher produces a `false` value and finishes. If the upstream publisher finishes normally, this publisher produces a `true` value and finishes. If the predicate throws an error, the publisher fails, passing the error to its downstream.
    /// As a `reduce`-style operator, this publisher produces at most one value.
    /// Backpressure note: Upon receiving any request greater than zero, this publisher requests unlimited elements from the upstream publisher.
    /// - Parameter predicate:  A closure that evaluates each received element. Return `true` to continue, or `false` to cancel the upstream and complete. The closure may throw, in which case the publisher cancels the upstream publisher and fails with the thrown error.
    /// - Returns:  A publisher that publishes a Boolean value that indicates whether all received elements pass a given predicate.
    public func tryAllSatisfy(_ predicate: @escaping (Self.Output) throws -> Bool) -> Publishers.TryAllSatisfy<Self> {
        return .init(upstream: self, predicate: predicate)
    }
}

extension Publishers {
    
    /// A publisher that publishes a single Boolean value that indicates whether all received elements pass a given error-throwing predicate.
    public struct TryAllSatisfy<Upstream> : Publisher where Upstream : Publisher {
        
        /// The kind of values published by this publisher.
        public typealias Output = Bool
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// A closure that evaluates each received element.
        ///
        /// Return `true` to continue, or `false` to cancel the upstream and complete. The closure may throw, in which case the publisher cancels the upstream publisher and fails with the thrown error.
        public let predicate: (Upstream.Output) throws -> Bool
        
        public init(upstream: Upstream, predicate: @escaping (Upstream.Output) throws -> Bool) {
            self.upstream = upstream
            self.predicate = predicate
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Publishers.TryAllSatisfy<Upstream>.Failure, S.Input == Publishers.TryAllSatisfy<Upstream>.Output {
            let s = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(s)
        }
    }
}

extension Publishers.TryAllSatisfy {
    
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
        
        typealias Pub = Publishers.TryAllSatisfy<Upstream>
        typealias Sub = S
        typealias Predicate = (Upstream.Output) throws -> Bool
        
        let lock = Lock()
        let predicate: Predicate
        let sub: Sub
        
        var state: RelayState = .waiting
        
        init(pub: Pub, sub: Sub) {
            self.predicate = pub.predicate
            self.sub = sub
        }
        
        func request(_ demand: Subscribers.Demand) {
            precondition(demand > 0)
            self.lock.withLockGet(self.state.subscription)?.request(.unlimited)
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
            
            do {
                if try self.predicate(input) {
                    self.lock.unlock()
                    return .none
                }
                
                let subscription = self.state.complete()!
                self.lock.unlock()
                
                subscription.cancel()
                
                _ = self.sub.receive(false)
                self.sub.receive(completion: .finished)
            } catch {
                let subscription = self.state.complete()!
                self.lock.unlock()
                
                subscription.cancel()
                
                self.sub.receive(completion: .failure(error))
            }
            
            return .none
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                return
            }
            
            subscription.cancel()
            
            switch completion {
            case .failure(let e):
                self.sub.receive(completion: .failure(e))
            case .finished:
                _ = self.sub.receive(true)
                self.sub.receive(completion: .finished)
            }
        }
        
        var description: String {
            return "TryAllSatisfy"
        }
        
        var debugDescription: String {
            return "TryAllSatisfy"
        }
    }
}
