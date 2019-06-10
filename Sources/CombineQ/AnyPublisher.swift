/// A type-erasing publisher.
///
/// Use `AnyPublisher` to wrap a publisher whose type has details you don’t want to expose to subscribers or other publishers.
public struct AnyPublisher<Output, Failure> where Failure : Error {
    
    @usableFromInline
    let subscribeBody: (AnySubscriber<Output, Failure>) -> Void
    
    /// Creates a type-erasing publisher to wrap the provided publisher.
    ///
    /// - Parameters:
    ///   - publisher: A publisher to wrap with a type-eraser.
    @inlinable public init<P>(_ publisher: P) where Output == P.Output, Failure == P.Failure, P : Publisher {
        self.subscribeBody = publisher.receive(subscriber:)
    }
    
    /// Creates a type-erasing publisher implemented by the provided closure.
    ///
    /// - Parameters:
    ///   - subscribe: A closure to invoke when a subscriber subscribes to the publisher.
    @inlinable public init(_ subscribe: @escaping (AnySubscriber<Output, Failure>) -> Void) {
        self.subscribeBody = subscribe
    }
}

extension AnyPublisher: Publisher {
    
    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    @inlinable public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber {
        self.subscribeBody(subscriber.eraseToAnySubscriber())
    }
}
