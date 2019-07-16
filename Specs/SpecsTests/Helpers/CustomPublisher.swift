#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class CustomPublisher<Output, Failure>: Publisher where Failure : Error {
    
    let subscribeBody: (AnySubscriber<Output, Failure>) -> Void
    
    init(_ subscribe: @escaping (AnySubscriber<Output, Failure>) -> Void) {
        self.subscribeBody = subscribe
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        self.subscribeBody(AnySubscriber(subscriber))
    }
}
