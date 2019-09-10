extension Optional {
    
    public enum CX {
    }
}

extension Optional: CombineXCompatible {
}

extension CombineXWrapper where Base: OptionalProtocol {
}

extension Optional.CX {
    
    /// A publisher that publishes an optional value to each subscriber exactly once, if the optional has a value.
    ///
    /// In contrast with `Just`, an `Optional` publisher may send no value before completion.
    public struct Publisher: __Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Wrapped

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Never

        /// The result to deliver to each subscriber.
        public let output: Wrapped?

        /// Creates a publisher to emit the optional value of a successful result, or fail with an error.
        ///
        /// - Parameter result: The result to deliver to each subscriber.
        public init(_ output: Output?) {
            self.output = output
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Wrapped == S.Input, S : Subscriber, S.Failure == Failure {
            guard let output = output else {
                subscriber.receive(subscription: Subscriptions.empty)
                subscriber.receive(completion: .finished)
                return
            }
            Just(output).receive(subscriber: subscriber)
        }
    }
}
