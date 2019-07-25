/// A publisher that awaits subscription before running the supplied closure to create a publisher for the new subscriber.
public struct Deferred<DeferredPublisher> : Publisher where DeferredPublisher : Publisher {
    
    /// The kind of values published by this publisher.
    public typealias Output = DeferredPublisher.Output
    
    /// The kind of errors this publisher might publish.
    ///
    /// Use `Never` if this `Publisher` does not publish errors.
    public typealias Failure = DeferredPublisher.Failure
    
    /// The closure to execute when it receives a subscription.
    ///
    /// The publisher returned by this closure immediately receives the incoming subscription.
    public let createPublisher: () -> DeferredPublisher
    
    /// Creates a deferred publisher.
    ///
    /// - Parameter createPublisher: The closure to execute when calling `subscribe(_:)`.
    public init(createPublisher: @escaping () -> DeferredPublisher) {
        self.createPublisher = createPublisher
    }
    
    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    public func receive<S>(subscriber: S) where S : Subscriber, DeferredPublisher.Failure == S.Failure, DeferredPublisher.Output == S.Input {
        self.createPublisher().receive(subscriber: subscriber)
    }
}
