/// A subject that passes along values and completion.
///
/// Use a `PassthroughSubject` in unit tests when you want a publisher than can publish specific values on-demand during tests.
final public class PassthroughSubject<Output, Failure> : Subject where Failure : Error {
    
    public init() {
    }
    
    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    final public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber {
        WaitForImplementation()
    }
    
    /// Sends a value to the subscriber.
    ///
    /// - Parameter value: The value to send.
    final public func send(_ input: Output) {
        WaitForImplementation()
    }
    
    /// Sends a completion signal to the subscriber.
    ///
    /// - Parameter completion: A `Completion` instance which indicates whether publishing has finished normally or failed with an error.
    final public func send(completion: Subscribers.Completion<Failure>) {
        WaitForImplementation()
    }
}
