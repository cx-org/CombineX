extension Subscribers {
    
    /// A simple subscriber that requests an unlimited number of values upon subscription.
    final public class Sink<Upstream> : Subscriber, Cancellable, CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible where Upstream : Publisher {
        
        /// The kind of values this subscriber receives.
        public typealias Input = Upstream.Output
        
        /// The kind of errors this subscriber might receive.
        ///
        /// Use `Never` if this `Subscriber` cannot receive errors.
        public typealias Failure = Upstream.Failure
        
        /// The closure to execute on receipt of a value.
        final public let receiveValue: (Upstream.Output) -> Void
        
        /// The closure to execute on completion.
        final public let receiveCompletion: ((Subscribers.Completion<Upstream.Failure>) -> Void)?
        
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
            return "[Sink]: \(self.combineIdentifier)"
        }
        
        /// The custom mirror for this instance.
        ///
        /// If this type has value semantics, the mirror should be unaffected by
        /// subsequent mutations of the instance.
        final public var customMirror: Mirror {
            Global.RequiresImplementation()
        }
        
        /// A custom playground description for this instance.
        final public var playgroundDescription: Any {
            Global.RequiresImplementation()
        }
        
        private let subscription = Atomic<Subscription?>(value: nil)
        
        /// Initializes a sink with the provided closures.
        ///
        /// - Parameters:
        ///   - receiveValue: The closure to execute on receipt of a value. If `nil`, the sink uses an empty closure.
        ///   - receiveCompletion: The closure to execute on completion. If `nil`, the sink uses an empty closure.
        public init(receiveCompletion: ((Subscribers.Completion<Subscribers.Sink<Upstream>.Failure>) -> Void)? = nil, receiveValue: @escaping ((Subscribers.Sink<Upstream>.Input) -> Void)) {
            self.receiveCompletion = receiveCompletion
            self.receiveValue = receiveValue
        }
        
        /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
        ///
        /// Use the received `Subscription` to request items from the publisher.
        /// - Parameter subscription: A subscription that represents the connection between publisher and subscriber.
        final public func receive(subscription: Subscription) {
            if Atomic.ifNil(self.subscription, store: subscription) {
                subscription.request(.unlimited)
            }
        }
        
        /// Tells the subscriber that the publisher has produced an element.
        ///
        /// - Parameter input: The published element.
        /// - Returns: A `Demand` instance indicating how many more elements the subcriber expects to receive.
        final public func receive(_ value: Subscribers.Sink<Upstream>.Input) -> Subscribers.Demand {
            self.receiveValue(value)
            return .max(0)
        }
        
        /// Tells the subscriber that the publisher has completed publishing, either normally or with an error.
        ///
        /// - Parameter completion: A `Completion` case indicating whether publishing completed normally or with an error.
        final public func receive(completion: Subscribers.Completion<Subscribers.Sink<Upstream>.Failure>) {
            self.receiveCompletion?(completion)
            self.subscription.exchange(with: nil)?.cancel()
        }
        
        /// Cancel the activity.
        final public func cancel() {
        }
        
        deinit {
            self.subscription.exchange(with: nil)?.cancel()
        }
    }
}
