/// A subject that wraps a single value and publishes a new element whenever the value changes.
final public class CurrentValueSubject<Output, Failure> : Subject where Failure : Error {
    
    /// The value wrapped by this subject, published as a new element whenever it changes.
    final public var value: Output {
        didSet {
            self.send(value)
        }
    }
    
    private let passthrough: PassthroughSubject<Output, Failure>
    
    /// Creates a current value subject with the given initial value.
    ///
    /// - Parameter value: The initial value to publish.
    public init(_ value: Output) {
        self.passthrough = PassthroughSubject()
        self.value = value
    }
    
    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    final public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber {
        self.passthrough.receive(subscriber: subscriber)
        self.passthrough.send(self.value)
    }
    
    /// Sends a value to the subscriber.
    ///
    /// - Parameter value: The value to send.
    final public func send(_ input: Output) {
        self.passthrough.send(input)
    }
    
    /// Sends a completion signal to the subscriber.
    ///
    /// - Parameter completion: A `Completion` instance which indicates whether publishing has finished normally or failed with an error.
    final public func send(completion: Subscribers.Completion<Failure>) {
        self.passthrough.send(completion: .finished)
    }
}
