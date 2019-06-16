final public class AnySubject<Output, Failure> : Subject where Failure : Error {
    
    private let anyPublisher: AnyPublisher<Output, Failure>
    private let sendValueBody: (Output) -> Void
    private let sendCompletionBody: (Subscribers.Completion<Failure>) -> Void
 
    public init<S>(_ subject: S) where Output == S.Output, Failure == S.Failure, S : Subject {
        self.anyPublisher = subject.eraseToAnyPublisher()
        
        self.sendValueBody = subject.send(_:)
        self.sendCompletionBody = subject.send(completion:)
    }
    
    public init(_ subscribe: @escaping (AnySubscriber<Output, Failure>) -> Void, _ receive: @escaping (Output) -> Void, _ receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void) {
        self.anyPublisher = AnyPublisher(subscribe)
        
        self.sendValueBody = receive
        self.sendCompletionBody = receiveCompletion
    }
    
    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    final public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber {
        self.anyPublisher.receive(subscriber: subscriber)
    }
    
    /// Sends a value to the subscriber.
    ///
    /// - Parameter value: The value to send.
    final public func send(_ value: Output) {
        self.sendValueBody(value)
    }
    
    /// Sends a completion signal to the subscriber.
    ///
    /// - Parameter completion: A `Completion` instance which indicates whether publishing has finished normally or failed with an error.
    final public func send(completion: Subscribers.Completion<Failure>) {
        self.sendCompletionBody(completion)
    }
}
