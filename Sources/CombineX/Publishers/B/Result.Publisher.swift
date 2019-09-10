extension Result {
    
    public enum CX {
    }
}

extension Result: CombineXCompatible {
}

extension CombineXWrapper where Base: ResultProtocol {
    
    public var publisher: Result<Base.Success, Base.Failure>.CX.Publisher {
        return .init(self.base.result)
    }
}

extension Result.CX {

    /// A publisher that publishes an output to each subscriber exactly once then finishes, or fails immediately without producing any elements.
    ///
    /// If `result` is `.success`, then `Once` waits until it receives a request for at least 1 value before sending the output. If `result` is `.failure`, then `Once` sends the failure immediately upon subscription.
    ///
    /// In contrast with `Just`, a `Once` publisher can terminate with an error instead of sending a value.
    /// In contrast with `Optional`, a `Once` publisher always sends one value (unless it terminates with an error).
    public struct Publisher: __Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Success

        /// The result to deliver to each subscriber.
        public let result: Result<Success, Failure>

        /// Creates a publisher that delivers the specified result.
        ///
        /// If the result is `.success`, the `Once` publisher sends the specified output to all subscribers and finishes normally. If the result is `.failure`, then the publisher fails immediately with the specified error.
        /// - Parameter result: The result to deliver to each subscriber.
        public init(_ result: Result<Output, Failure>) {
            self.result = result
        }

        /// Creates a publisher that sends the specified output to all subscribers and finishes normally.
        ///
        /// - Parameter output: The output to deliver to each subscriber.
        public init(_ output: Output) {
            self.result = .success(output)
        }

        /// Creates a publisher that immediately terminates upon subscription with the given failure.
        ///
        /// - Parameter failure: The failure to send when terminating.
        public init(_ failure: Failure) {
            self.result = .failure(failure)
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Success == S.Input, Failure == S.Failure, S : Subscriber {
            switch result {
            case .failure(let e):
                subscriber.receive(subscription: Subscriptions.empty)
                subscriber.receive(completion: .failure(e))
            case .success(let output):
                let s = Inner(output: output, sub: subscriber)
                subscriber.receive(subscription: s)
            }
        }
    }
}

extension Result.CX.Publisher {
    
    private final class Inner<S>:
        Subscription,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S : Subscriber,
        S.Input == Output,
        S.Failure == Failure
    {
        
        typealias Sub = S
        
        let lock = Lock()
        let output: Output
        
        var state = DemandState.waiting
        var sub: Sub?
        
        init(output: Output, sub: Sub) {
            self.output = output
            self.sub = sub
        }
        
        func request(_ demand: Subscribers.Demand) {
            precondition(demand > 0)

            self.lock.lock()
            guard self.state.isWaiting else {
                self.lock.unlock()
                return
            }
            
            self.state = .completed
            
            let sub = self.sub!
            self.sub = nil
            
            self.lock.unlock()
            
            _ = sub.receive(output)
            sub.receive(completion: .finished)
        }
        
        func cancel() {
            self.lock.withLock {
                self.state = .completed
                self.sub = nil
            }
        }
        
        var description: String {
            return "Result.Publisher"
        }
        
        var debugDescription: String {
            return "Result.Publisher"
        }
    }
}
