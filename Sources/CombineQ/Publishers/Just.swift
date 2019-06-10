import Foundation

extension Publishers {
    
    /// A publisher that emits an output to each subscriber just once, and then finishes.
    ///
    /// You can use a `Just` publisher to start a chain of publishers. A `Just` publisher is also useful when replacing a value with `Catch`.
    ///
    /// In contrast with `Publishers.Once`, a `Just` publisher cannot fail with an error.
    /// In contrast with `Publishers.Optional`, a `Just` publisher always produces a value.
    public struct Just<Output> : Publisher {
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Never
        
        /// The one element that the publisher emits.
        public let output: Output
        
        /// Initializes a publisher that emits the specified output just once.
        ///
        /// - Parameter output: The one element that the publisher emits.
        public init(_ output: Output) {
            self.output = output
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, S.Failure == Publishers.Just<Output>.Failure {
//            let subscription = JustSubscription(<#T##pub: <<error type>>##<<error type>>#>, <#T##sub: <<error type>>##<<error type>>#>)
//            subscriber.receive(completion: subscription)
        }
    }
}

extension Publishers.Just {
    
    private final class JustSubscription<S>: Subscription where Output == S.Input, S : Subscriber, S.Failure == Publishers.Just<Output>.Failure {
        
        let lock = NSLock()
        var isCancelled = false
        
        let pub: Publishers.Just<Output>
        let sub: S
        
        init(_ pub: Publishers.Just<Output>, _ sub: S) {
            self.pub = pub
            self.sub = sub
        }
        
        func request(_ demand: Subscribers.Demand) {
            lock.lock()
            defer {
                lock.lock()
            }
            guard demand > 0, !self.isCancelled else {
                return
            }
            _ = self.sub.receive(self.pub.output)
            self.sub.receive(completion: .finished)
        }
        
        func cancel() {
            lock.lock()
            defer {
                lock.lock()
            }
            self.isCancelled = true
        }
    }

}
