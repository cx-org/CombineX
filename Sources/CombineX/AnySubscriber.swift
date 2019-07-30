/// A type-erasing subscriber.
///
/// Use an `AnySubscriber` to wrap an existing subscriber whose details you don’t want to expose.
/// You can also use `AnySubscriber` to create a custom subscriber by providing closures for `Subscriber`’s methods, rather than implementing `Subscriber` directly.
public struct AnySubscriber<Input, Failure> : Subscriber, CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible where Failure : Error {
    
    public let combineIdentifier = CombineIdentifier()
    
    @usableFromInline
    let receiveSubscriptionBody: ((Subscription) -> Void)?
    @usableFromInline
    let receiveValueBody: ((Input) -> Subscribers.Demand)?
    @usableFromInline
    let receiveCompletionBody: ((Subscribers.Completion<Failure>) -> Void)?
    
    private var subscription: Atom<Subscription?>?
    
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
    public var description: String {
        return "AnySubscriber"
    }
    
    /// The custom mirror for this instance.
    ///
    /// If this type has value semantics, the mirror should be unaffected by
    /// subsequent mutations of the instance.
    public var customMirror: Mirror {
        return Mirror(self, children: EmptyCollection())
    }
    
    /// A custom playground description for this instance.
    public var playgroundDescription: Any {
        return self.description
    }
    
    /// Creates a type-erasing subscriber to wrap an existing subscriber.
    ///
    /// - Parameter s: The subscriber to type-erase.
    @inlinable public init<S>(_ s: S) where Input == S.Input, Failure == S.Failure, S : Subscriber {
        self.receiveSubscriptionBody = s.receive(subscription:)
        self.receiveValueBody = s.receive(_:)
        self.receiveCompletionBody = s.receive(completion:)
    }
    
    public init<S>(_ s: S) where Input == S.Output, Failure == S.Failure, S : Subject {
        
        let subscription = Atom<Subscription?>(val: nil)
        
        self.receiveSubscriptionBody = {
            subscription.set($0)
            $0.request(.unlimited)
        }
        
        self.receiveValueBody = { v in
            precondition(subscription.get().isNotNil)
            s.send(v)
            return .none
        }

        self.receiveCompletionBody = { c in
            precondition(subscription.get().isNotNil)
            s.send(completion: c)
        }
        
        self.subscription = subscription
    }
    
    func cancel() {
        self.subscription?.exchange(with: nil)?.cancel()
    }
    
    /// Creates a type-erasing subscriber that executes the provided closures.
    ///
    /// - Parameters:
    ///   - receiveSubscription: A closure to execute when the subscriber receives the initial subscription from the publisher.
    ///   - receiveValue: A closure to execute when the subscriber receives a value from the publisher.
    ///   - receiveCompletion: A closure to execute when the subscriber receives a completion callback from the publisher.
    @inlinable public init(receiveSubscription: ((Subscription) -> Void)? = nil, receiveValue: ((Input) -> Subscribers.Demand)? = nil, receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil) {
        self.receiveSubscriptionBody = receiveSubscription
        self.receiveValueBody = receiveValue
        self.receiveCompletionBody = receiveCompletion
    }
    
    /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
    ///
    /// Use the received `Subscription` to request items from the publisher.
    /// - Parameter subscription: A subscription that represents the connection between publisher and subscriber.
    @inlinable public func receive(subscription: Subscription) {
        self.receiveSubscriptionBody?(subscription)
    }
    
    /// Tells the subscriber that the publisher has produced an element.
    ///
    /// - Parameter input: The published element.
    /// - Returns: A `Demand` instance indicating how many more elements the subcriber expects to receive.
    @inlinable public func receive(_ value: Input) -> Subscribers.Demand {
        return self.receiveValueBody?(value) ?? .none
    }
    
    /// Tells the subscriber that the publisher has completed publishing, either normally or with an error.
    ///
    /// - Parameter completion: A `Completion` case indicating whether publishing completed normally or with an error.
    @inlinable public func receive(completion: Subscribers.Completion<Failure>) {
        self.receiveCompletionBody?(completion)
    }
}
