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
    public func output<R>(in range: R) -> Publishers.Output<Self> where R : RangeExpression, R.Bound == Int {
        return .init(upstream: self, range: range.relative(to: 0..<Int.max))
    }
}

extension Publishers.Output : Equatable where Upstream : Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.Output<Upstream>, rhs: Publishers.Output<Upstream>) -> Bool {
        return lhs.upstream == rhs.upstream && lhs.range == rhs.range
    }
}

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
    public struct Output<Upstream> : Publisher where Upstream : Publisher {
        
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
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
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            let subscription = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(subscription)
        }
    }
}

extension Publishers.Output {
    
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
        
        typealias Pub = Publishers.Output<Upstream>
        typealias Sub = S
        
        let lock = Lock()
        var state = RelayState.waiting
        var count = 0
        
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
            let subscription = self.state.subscription
            self.state = .finished
            self.lock.unlock()
            
            subscription?.cancel()
            
            self.pub = nil
            self.sub = nil
        }
        
        func receive(subscription: Subscription) {
            self.lock.lock()
            
            if self.state.isWaiting {
                self.state = .relaying(subscription)
                self.lock.unlock()
                
                self.sub?.receive(subscription: self)
            } else {
                self.lock.unlock()
                subscription.cancel()
            }
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            self.lock.lock()
            
            guard
                self.state.isRelaying,
                let range = self.pub?.range,
                let sub = self.sub,
                range.contains(self.count)
            else {
                self.count += 1
                self.lock.unlock()
                return .max(1)
            }
            
            self.count += 1
            self.lock.unlock()
            
            let demand = sub.receive(input)
            if self.count == range.upperBound {
                self.state.subscription?.cancel()
                sub.receive(completion: .finished)
                
                self.pub = nil
                self.sub = nil
            }
            return demand
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            self.lock.lock()
            guard let subscription = self.state.subscription else {
                self.lock.unlock()
                return
            }
            
            subscription.cancel()
            
            self.sub?.receive(completion: completion)
            self.pub = nil
            self.sub = nil
        }
        
        var description: String {
            return "Output"
        }
        
        var debugDescription: String {
            return "Output"
        }
    }
}
