extension Publisher {
    
    /// Replaces any errors in the stream with the provided element.
    ///
    /// If the upstream publisher fails with an error, this publisher emits the provided element, then finishes normally.
    /// - Parameter output: An element to emit when the upstream publisher fails.
    /// - Returns: A publisher that replaces an error from the upstream publisher with the provided output element.
    public func replaceError(with output: Self.Output) -> Publishers.ReplaceError<Self> {
        return .init(upstream: self, output: output)
    }
}

extension Publishers.ReplaceError : Equatable where Upstream : Equatable, Upstream.Output : Equatable {
    
    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A replace error publisher to compare for equality.
    ///   - rhs: Another replace error publisher to compare for equality.
    /// - Returns: `true` if the two publishers have equal upstream publishers and output elements, `false` otherwise.
    public static func == (lhs: Publishers.ReplaceError<Upstream>, rhs: Publishers.ReplaceError<Upstream>) -> Bool {
        return lhs.upstream == rhs.upstream && lhs.output == rhs.output
    }
}

extension Publishers {
    
    /// A publisher that replaces any errors in the stream with a provided element.
    public struct ReplaceError<Upstream> : Publisher where Upstream : Publisher {
        
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Never
        
        /// The element with which to replace errors from the upstream publisher.
        public let output: Upstream.Output
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        public init(upstream: Upstream, output: Publishers.ReplaceError<Upstream>.Output) {
            self.upstream = upstream
            self.output = output
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Output == S.Input, S.Failure == Publishers.ReplaceError<Upstream>.Failure {
            let s = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(s)
        }
    }
}

extension Publishers.ReplaceError {
    
    private final class Inner<S>:
        Subscription,
        Subscriber,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Upstream.Output,
        S.Failure == Failure
    {
        
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        typealias Pub = Publishers.ReplaceError<Upstream>
        typealias Sub = S
        
        let lock = Lock()
        let output: Upstream.Output
        let sub: Sub
        
        var state = RelayState.waiting
        
        init(pub: Pub, sub: Sub) {
            self.output = pub.output
            self.sub = sub
        }
        
        func request(_ demand: Subscribers.Demand) {
            precondition(demand > 0)
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
            guard self.lock.withLockGet(self.state.isRelaying) else {
                return .none
            }
            
            return self.sub.receive(input)
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                return
            }
            
            subscription.cancel()
            
            switch completion {
            case .finished:
                self.sub.receive(completion: .finished)
            case .failure:
                _ = self.sub.receive(self.output)
                self.sub.receive(completion: .finished)
            }
        }
        
        var description: String {
            return "ReplaceError"
        }
        
        var debugDescription: String {
            return "ReplaceError"
        }
    }
}
