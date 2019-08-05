/// A type-erasing subscriber.
///
/// Use an `AnySubscriber` to wrap an existing subscriber whose details you don’t want to expose.
/// You can also use `AnySubscriber` to create a custom subscriber by providing closures for `Subscriber`’s methods, rather than implementing `Subscriber` directly.
public struct AnySubscriber<Input, Failure> : Subscriber, CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible where Failure : Error {
    
    public let combineIdentifier: CombineIdentifier
    
    @usableFromInline
    let box: SubscriberBox<Input, Failure>
    
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
    @inlinable
    public init<S>(_ s: S) where Input == S.Input, Failure == S.Failure, S : Subscriber {
        self.box = ClosureSubscriberBox<Input, Failure>(receiveSubscription: s.receive(subscription:), receiveValue: s.receive(_:), receiveCompletion: s.receive(completion:))
        self.combineIdentifier = s.combineIdentifier
    }
    
    public init<S>(_ s: S) where Input == S.Output, Failure == S.Failure, S : Subject {
        self.box = SubjectSubscriberBox(s)
        self.combineIdentifier = CombineIdentifier(s)
    }
    
    /// Creates a type-erasing subscriber that executes the provided closures.
    ///
    /// - Parameters:
    ///   - receiveSubscription: A closure to execute when the subscriber receives the initial subscription from the publisher.
    ///   - receiveValue: A closure to execute when the subscriber receives a value from the publisher.
    ///   - receiveCompletion: A closure to execute when the subscriber receives a completion callback from the publisher.
    @inlinable
    public init(receiveSubscription: ((Subscription) -> Void)? = nil, receiveValue: ((Input) -> Subscribers.Demand)? = nil, receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil) {
        self.box = ClosureSubscriberBox<Input, Failure>(receiveSubscription: receiveSubscription, receiveValue: receiveValue, receiveCompletion: receiveCompletion)
        self.combineIdentifier = CombineIdentifier()
    }
    
    /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
    ///
    /// Use the received `Subscription` to request items from the publisher.
    /// - Parameter subscription: A subscription that represents the connection between publisher and subscriber.
    @inlinable
    public func receive(subscription: Subscription) {
        self.box.receive(subscription: subscription)
    }
    
    /// Tells the subscriber that the publisher has produced an element.
    ///
    /// - Parameter input: The published element.
    /// - Returns: A `Demand` instance indicating how many more elements the subcriber expects to receive.
    @inlinable
    public func receive(_ value: Input) -> Subscribers.Demand {
        return self.box.receive(value)
    }
    
    /// Tells the subscriber that the publisher has completed publishing, either normally or with an error.
    ///
    /// - Parameter completion: A `Completion` case indicating whether publishing completed normally or with an error.
    @inlinable
    public func receive(completion: Subscribers.Completion<Failure>) {
        self.box.receive(completion: completion)
    }
}


@usableFromInline
class SubscriberBox<Input, Failure>: Subscriber, Cancellable where Failure: Error {
    
    @inlinable
    init() {
    }
    
    @inlinable
    func receive(subscription: Subscription) {
        Global.RequiresConcreteImplementation()
    }
    
    @inlinable
    func receive(_ input: Input) -> Subscribers.Demand {
        Global.RequiresConcreteImplementation()
    }
    
    @inlinable
    func receive(completion: Subscribers.Completion<Failure>) {
        Global.RequiresConcreteImplementation()
    }
    
    @inlinable
    func cancel() {
        Global.RequiresConcreteImplementation()
    }
}

@usableFromInline
class ClosureSubscriberBox<Input, Failure>: SubscriberBox<Input, Failure> where Failure: Error {
    
    @usableFromInline
    let receiveSubscriptionBody: ((Subscription) -> Void)?
    @usableFromInline
    let receiveValueBody: ((Input) -> Subscribers.Demand)?
    @usableFromInline
    let receiveCompletionBody: ((Subscribers.Completion<Failure>) -> Void)?
    
    @inlinable
    init(receiveSubscription: ((Subscription) -> Void)? = nil, receiveValue: ((Input) -> Subscribers.Demand)? = nil, receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil) {
        self.receiveSubscriptionBody = receiveSubscription
        self.receiveValueBody = receiveValue
        self.receiveCompletionBody = receiveCompletion
    }
    
    @inlinable
    override func receive(subscription: Subscription) {
        self.receiveSubscriptionBody?(subscription)
    }
    
    @inlinable
    override func receive(_ input: Input) -> Subscribers.Demand {
        return self.receiveValueBody?(input) ?? .none
    }
    
    @inlinable
    override func receive(completion: Subscribers.Completion<Failure>) {
        self.receiveCompletionBody?(completion)
    }
    
    @inlinable
    override func cancel() {
    }
}

@usableFromInline
class SubjectSubscriberBox<S: Subject>: SubscriberBox<S.Output, S.Failure> {
    
    @usableFromInline
    let lock = Lock()
    @usableFromInline
    var subject: S?
    @usableFromInline
    var state: RelayState = .waiting
    
    @usableFromInline
    init(_ s: S) {
        self.subject = s
    }
    
    @inlinable
    override func receive(subscription: Subscription) {
        self.lock.lock()
        guard self.state.relay(subscription) else {
            self.lock.unlock()
            subscription.cancel()
            return
        }
        let subject = self.subject
        self.lock.unlock()
        
        subject?.send(subscription: subscription)
    }
    
    @inlinable
    override func receive(_ input: Input) -> Subscribers.Demand {
        self.lock.lock()
        switch self.state {
        case .waiting:
            self.lock.unlock()
            fatalError()
        case .relaying:
            let subject = self.subject!
            self.lock.unlock()
            subject.send(input)
            return .none
        case .completed:
            self.lock.unlock()
            return .none
        }
    }
    
    @inlinable
    override func receive(completion: Subscribers.Completion<Failure>) {
        self.lock.lock()
        switch self.state {
        case .waiting:
            self.lock.unlock()
            fatalError()
        case .relaying:
            self.state = .completed
            let subject = self.subject!
            self.lock.unlock()
            subject.send(completion: completion)
        case .completed:
            self.lock.unlock()
        }
    }
    
    @inlinable
    override func cancel() {
        guard let subscription = self.lock.withLockGet(self.state.complete()) else {
            return
        }
        subscription.cancel()
        self.subject = nil
    }
}
