extension Publisher {
    
    public func eraseToAnyPublisher() -> AnyPublisher<Self.Output, Self.Failure> {
        return AnyPublisher(self)
    }
}

extension AnyPublisher: Publisher {
    
    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    @inlinable
    public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber {
        self.subscribeBody(subscriber.eraseToAnySubscriber())
    }
}

/// A type-erasing publisher.
///
/// Use `AnyPublisher` to wrap a publisher whose type has details you don’t want to expose to subscribers or other publishers.
public struct AnyPublisher<Output, Failure> : CustomStringConvertible, CustomPlaygroundDisplayConvertible where Failure : Error {
    
    @usableFromInline
    let subscribeBody: (AnySubscriber<Output, Failure>) -> Void
    
    public var description: String {
        return "AnyPublisher"
    }

    /// A custom playground description for this instance.
    public var playgroundDescription: Any {
        return self.description
    }
    
    /// Creates a type-erasing publisher to wrap the provided publisher.
    ///
    /// - Parameters:
    ///   - publisher: A publisher to wrap with a type-eraser.
    @inlinable
    public init<P>(_ publisher: P) where Output == P.Output, Failure == P.Failure, P : Publisher {
        self.subscribeBody = publisher.subscribe(_:)
    }
}
