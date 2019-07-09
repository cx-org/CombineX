final public class Future<Output, Failure> : Publisher where Failure : Error {
    
    public typealias Promise = (Result<Output, Failure>) -> Void
    
    let subject = CurrentValueSubject<Output?, Failure>(nil)
    
    public init(_ attemptToFulfill: @escaping (@escaping Future<Output, Failure>.Promise) -> Void) {
        attemptToFulfill(self.complete)
    }
    
    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    final public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber {
        if let output = self.subject.value {
            Publishers.Once<Output, Failure>(output).receive(subscriber: subscriber)
        } else {
            self.subject
                .compactMap { $0 }
                .receive(subscriber: subscriber)
        }
    }
    
    private func complete(_ result: Result<Output, Failure>) {
        switch result {
        case .success(let output):
            self.subject.send(output)
            self.subject.send(completion: .finished)
        case .failure(let error):
            self.subject.send(completion: .failure(error))
        }
    }
}
