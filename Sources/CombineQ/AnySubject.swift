final public class AnySubject<Output, Failure> : Subject where Failure : Error {
    
    public init<S>(_ subject: S) where Output == S.Output, Failure == S.Failure, S : Subject
    
    public init(_ subscribe: @escaping (AnySubscriber<Output, Failure>) -> Void, _ receive: @escaping (Output) -> Void, _ receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void)
    
    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    final public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber
    
    /// Sends a value to the subscriber.
    ///
    /// - Parameter value: The value to send.
    final public func send(_ value: Output)
    
    /// Sends a completion signal to the subscriber.
    ///
    /// - Parameter completion: A `Completion` instance which indicates whether publishing has finished normally or failed with an error.
    final public func send(completion: Subscribers.Completion<Failure>)
}
