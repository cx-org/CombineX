import CXShim

public class TestPublisher<Output, Failure>: Publisher where Failure : Error {
    
    let subscribeBody: (AnySubscriber<Output, Failure>) -> Void
    
    public init(_ subscribe: @escaping (AnySubscriber<Output, Failure>) -> Void) {
        self.subscribeBody = subscribe
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        self.subscribeBody(AnySubscriber(subscriber))
    }
}
