#if !COCOAPODS
import CXUtility
#endif

extension Publisher {
    
    /// Attaches a subscriber with closure-based behavior.
    ///
    /// This method creates the subscriber and immediately requests an unlimited number of values, prior to returning the subscriber.
    /// - parameter receiveComplete: The closure to execute on completion.
    /// - parameter receiveValue: The closure to execute on receipt of a value.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    public func sink(receiveCompletion: @escaping ((Subscribers.Completion<Failure>) -> Void), receiveValue: @escaping ((Output) -> Void)) -> AnyCancellable {
        let sink = Subscribers.Sink<Output, Failure>(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
        self.subscribe(sink)
        return AnyCancellable(sink)
    }
}

extension Publisher where Failure == Never {

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// This method creates the subscriber and immediately requests an unlimited number of values, prior to returning the subscriber.
    /// - parameter receiveValue: The closure to execute on receipt of a value.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    public func sink(receiveValue: @escaping ((Output) -> Void)) -> AnyCancellable {
        let sink = Subscribers.Sink<Output, Failure>(receiveCompletion: { _ in }, receiveValue: receiveValue)
        self.subscribe(sink)
        return AnyCancellable(sink)
    }
}

extension Subscribers {
    
    /// A simple subscriber that requests an unlimited number of values upon subscription.
    final public class Sink<Input, Failure: Error>: Subscriber, Cancellable, CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible {
        
        /// The closure to execute on receipt of a value.
        final public let receiveValue: (Input) -> Void
        
        /// The closure to execute on completion.
        final public let receiveCompletion: (Subscribers.Completion<Failure>) -> Void
        
        /// Initializes a sink with the provided closures.
        ///
        /// - Parameters:
        ///   - receiveCompletion: The closure to execute on completion.
        ///   - receiveValue: The closure to execute on receipt of a value.
        public init(receiveCompletion: @escaping ((Subscribers.Completion<Failure>) -> Void), receiveValue: @escaping ((Input) -> Void)) {
            self.receiveCompletion = receiveCompletion
            self.receiveValue = receiveValue
        }
        
        final public var description: String {
            return "Sink"
        }
        
        final public var customMirror: Mirror {
            return Mirror(self, children: EmptyCollection())
        }
        
        final public var playgroundDescription: Any {
            return self.description
        }
        
        enum State {
            case unsubscribed
            case subscribed(Subscription)
            case closed
        }

        private let state = Atom<State>(val: .unsubscribed)
        
        final public func receive(subscription: Subscription) {
            var didSet = false
            self.state.withLockMutating { state in
                guard case .unsubscribed = state else {
                    return
                }

                state = .subscribed(subscription)
                didSet = true
            }

            if didSet {
                subscription.request(.unlimited)
            } else {
                subscription.cancel()
            }
        }
        
        final public func receive(_ value: Input) -> Subscribers.Demand {
            self.receiveValue(value)
            return .none
        }
        
        final public func receive(completion: Subscribers.Completion<Failure>) {
            self.receiveCompletion(completion)
            _ = self.state.exchange(with: .closed)
        }
        
        final public func cancel() {
            let oldState = self.state.exchange(with: .closed)
            if case let .subscribed(subscription) = oldState {
                subscription.cancel()
            }
        }
    }
}
