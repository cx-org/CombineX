extension Subscribers {
    
    final public class Assign<Root, Input> : Subscriber, Cancellable, CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible {
        
        /// The kind of errors this subscriber might receive.
        ///
        /// Use `Never` if this `Subscriber` cannot receive errors.
        public typealias Failure = Never
        
        final public private(set) var object: Root?
        
        final public let keyPath: ReferenceWritableKeyPath<Root, Input>
        
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
            return "[Assign]: \(self.combineIdentifier)"
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
        
        public init(object: Root, keyPath: ReferenceWritableKeyPath<Root, Input>) {
            self.object = object
            self.keyPath = keyPath
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
        final public func receive(_ value: Input) -> Subscribers.Demand {
            if self.subscription.load() == nil {
                return .none
            }
            
            self.object?[keyPath: self.keyPath] = value
            return .none
        }
        
        /// Tells the subscriber that the publisher has completed publishing, either normally or with an error.
        ///
        /// - Parameter completion: A `Completion` case indicating whether publishing completed normally or with an error.
        final public func receive(completion: Subscribers.Completion<Never>) {
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
