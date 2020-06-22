#if !COCOAPODS
import CXUtility
#endif

extension Publisher {
    
    /// Publishes a specific element, indicated by its index in the sequence of published elements.
    ///
    /// If the publisher completes normally or with an error before publishing the specified element, then the publisher doesn’t produce any elements.
    /// - Parameter index: The index that indicates the element to publish.
    /// - Returns: A publisher that publishes a specific indexed element.
    public func output(at index: Int) -> Publishers.Output<Self> {
        return .init(upstream: self, range: index..<index + 1)
    }
    
    /// Publishes elements specified by their range in the sequence of published elements.
    ///
    /// After all elements are published, the publisher finishes normally.
    /// If the publisher completes normally or with an error before producing all the elements in the range, it doesn’t publish the remaining elements.
    /// - Parameter range: A range that indicates which elements to publish.
    /// - Returns: A publisher that publishes elements specified by a range.
    public func output<R: RangeExpression>(in range: R) -> Publishers.Output<Self> where R.Bound == Int {
        return .init(upstream: self, range: range.relative(to: 0..<Int.max))
    }
}

extension Publishers.Output: Equatable where Upstream: Equatable {}

extension Publisher {
    
    /// Republishes elements up to the specified maximum count.
    ///
    /// - Parameter maxLength: The maximum number of elements to republish.
    /// - Returns: A publisher that publishes up to the specified number of elements before completing.
    public func prefix(_ maxLength: Int) -> Publishers.Output<Self> {
        return self.output(in: 0..<maxLength)
    }
}

extension Publishers {
    
    /// A publisher that publishes elements specified by a range in the sequence of published elements.
    public struct Output<Upstream: Publisher>: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream
        
        /// The range of elements to publish.
        public let range: CountableRange<Int>
        
        /// Creates a publisher that publishes elements specified by a range.
        ///
        /// - Parameters:
        ///   - upstream: The publisher that this publisher receives elements from.
        ///   - range: The range of elements to publish.
        public init(upstream: Upstream, range: CountableRange<Int>) {
            self.upstream = upstream
            self.range = range
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            let s = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(s)
        }
    }
}

extension Publishers.Output {
    
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
        
        typealias Pub = Publishers.Output<Upstream>
        typealias Sub = S
        
        let lock = Lock()
        let range: CountableRange<Int>
        let sub: Sub
        
        var index = -1
        var state = RelayState.waiting
        
        init(pub: Pub, sub: Sub) {
            self.range = pub.range
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
            
            self.index += 1
            let index = self.index
            self.lock.unlock()
            
            guard self.range.contains(index) else {
                return .max(1)
            }
            let demand = self.sub.receive(input)
            
            if index == self.range.upperBound - 1 {
                guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                    return .none
                }

                subscription.cancel()
                self.sub.receive(completion: .finished)
            }
            
            return demand
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                return
            }
            
            subscription.cancel()
            self.sub.receive(completion: completion)
        }
        
        var description: String {
            return "Output"
        }
        
        var debugDescription: String {
            return "Output"
        }
    }
}
