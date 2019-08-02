extension Publisher {
    
    /// Attaches a subscriber with closure-based behavior.
    ///
    /// This method creates the subscriber and immediately requests an unlimited number of values, prior to returning the subscriber.
    /// - parameter receiveComplete: The closure to execute on completion.
    /// - parameter receiveValue: The closure to execute on receipt of a value.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    public func sink(receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void), receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        let sink = Subscribers.Sink<Self.Output, Self.Failure>(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
        self.subscribe(sink)
        return AnyCancellable(sink)
    }
}

extension Publisher where Self.Failure == Never {

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// This method creates the subscriber and immediately requests an unlimited number of values, prior to returning the subscriber.
    /// - parameter receiveValue: The closure to execute on receipt of a value.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    public func sink(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        let sink = Subscribers.Sink<Self.Output, Self.Failure>(receiveCompletion: { _ in }, receiveValue: receiveValue)
        self.subscribe(sink)
        return AnyCancellable(sink)
    }
}

extension Subscribers {
    
    /// A simple subscriber that requests an unlimited number of values upon subscription.
    final public class Sink<Input, Failure> : Subscriber, Cancellable, CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible where Failure : Error {
        
        /// The closure to execute on receipt of a value.
        final public let receiveValue: (Input) -> Void
        
        /// The closure to execute on completion.
        final public let receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)?
        
        /// Initializes a sink with the provided closures.
        ///
        /// - Parameters:
        ///   - receiveCompletion: The closure to execute on completion.
        ///   - receiveValue: The closure to execute on receipt of a value.
        public init(receiveCompletion: @escaping ((Subscribers.Completion<Failure>) -> Void), receiveValue: @escaping ((Input) -> Void)) {
            self.receiveCompletion = receiveCompletion
            self.receiveValue = receiveValue
        }
        
        /// A textual representation of this instance.
        ///
        /// Calling this property directly is discouraged. Instead, convert an
        /// instance of any type to a string by using the `String(describing:)`
        /// initializer. This initializer works with any type, and uses the custom
        /// `description` property for types that conform to
        /// `CustomStringConvertible`:
        ///
        ///     struct Point: CustomStringConvertible {
        ///         let x: Int, y: Int
        ///
        ///         var description: String {
        ///             return "(\(x), \(y))"
        ///         }
        ///     }
        ///
        ///     let p = Point(x: 21, y: 30)
        ///     let s = String(describing: p)
        ///     print(s)
        ///     // Prints "(21, 30)"
        ///
        /// The conversion of `p` to a string in the assignment to `s` uses the
        /// `Point` type's `description` property.
        final public var description: String {
            return "Sink"
        }
        
        /// The custom mirror for this instance.
        ///
        /// If this type has value semantics, the mirror should be unaffected by
        /// subsequent mutations of the instance.
        final public var customMirror: Mirror {
            return Mirror(self, children: EmptyCollection())
        }
        
        /// A custom playground description for this instance.
        final public var playgroundDescription: Any {
            return self.description
        }
        
        private let subscription = Atom<Subscription?>(val: nil)
        
        /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
        ///
        /// Use the received `Subscription` to request items from the publisher.
        /// - Parameter subscription: A subscription that represents the connection between publisher and subscriber.
        final public func receive(subscription: Subscription) {
            if self.subscription.setIfNil(subscription) {
                subscription.request(.unlimited)
            } else {
                subscription.cancel()
            }
        }
        
        /// Tells the subscriber that the publisher has produced an element.
        ///
        /// - Parameter input: The published element.
        /// - Returns: A `Demand` instance indicating how many more elements the subcriber expects to receive.
        final public func receive(_ value: Input) -> Subscribers.Demand {
            self.receiveValue(value)
            return .none
        }
        
        /// Tells the subscriber that the publisher has completed publishing, either normally or with an error.
        ///
        /// - Parameter completion: A `Completion` case indicating whether publishing completed normally or with an error.
        final public func receive(completion: Subscribers.Completion<Failure>) {
            self.receiveCompletion?(completion)
            _ = self.subscription.exchange(with: nil)
        }
        
        /// Cancel the activity.
        final public func cancel() {
            self.subscription.exchange(with: nil)?.cancel()
        }
    }
}
