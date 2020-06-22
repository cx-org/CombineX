#if !COCOAPODS
import CXUtility
#endif

/// A type-erasing subscriber.
///
/// Use an `AnySubscriber` to wrap an existing subscriber whose details you don’t want to expose.
/// You can also use `AnySubscriber` to create a custom subscriber by providing closures for `Subscriber`’s methods, rather than implementing `Subscriber` directly.
public struct AnySubscriber<Input, Failure: Error>: Subscriber, CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible {
    
    @usableFromInline
    let box: AnySubscriberBase<Input, Failure>
    
    @usableFromInline
    let descriptionThunk: () -> String
    @usableFromInline
    let customMirrorThunk: () -> Mirror
    @usableFromInline
    let playgroundDescriptionThunk: () -> Any
    
    public let combineIdentifier: CombineIdentifier
    
    public var description: String {
        return descriptionThunk()
    }
    
    public var customMirror: Mirror {
        return customMirrorThunk()
    }
    
    public var playgroundDescription: Any {
        return playgroundDescriptionThunk()
    }
    
    /// Creates a type-erasing subscriber to wrap an existing subscriber.
    ///
    /// - Parameter s: The subscriber to type-erase.
    @inlinable
    public init<S: Subscriber>(_ s: S) where Input == S.Input, Failure == S.Failure {
        combineIdentifier = s.combineIdentifier
        box = AnySubscriberBox(s)
        
        if let desc = s as? CustomStringConvertible {
            descriptionThunk = {
                return desc.description
            }
        } else {
            let fixedDescription = "\(type(of: s))"
            descriptionThunk = { fixedDescription }
        }

        customMirrorThunk = {
            if let mir = s as? CustomReflectable {
                return mir.customMirror
            } else {
                return Mirror(s, children: [:])
            }
        }

        if let play = s as? CustomPlaygroundDisplayConvertible {
            playgroundDescriptionThunk = { play.playgroundDescription }
        } else if let desc = s as? CustomStringConvertible {
            playgroundDescriptionThunk = { desc.description }
        } else {
            let fixedDescription = "\(type(of: s))"
            playgroundDescriptionThunk = { fixedDescription }
        }
    }
    
    public init<S: Subject>(_ s: S) where Input == S.Output, Failure == S.Failure {
        self.init(SubjectSubscriberBox(s))
    }
    
    /// Creates a type-erasing subscriber that executes the provided closures.
    ///
    /// - Parameters:
    ///   - receiveSubscription: A closure to execute when the subscriber receives the initial subscription from the publisher.
    ///   - receiveValue: A closure to execute when the subscriber receives a value from the publisher.
    ///   - receiveCompletion: A closure to execute when the subscriber receives a completion callback from the publisher.
    @inlinable
    public init(
        receiveSubscription: ((Subscription) -> Void)? = nil,
        receiveValue: ((Input) -> Subscribers.Demand)? = nil,
        receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil
    ) {
        box = ClosureBasedAnySubscriber(
            receiveSubscription ?? { _ in },
            receiveValue ?? { _ in return .none },
            receiveCompletion ?? { _ in }
        )
        
        combineIdentifier = CombineIdentifier()
        descriptionThunk = {
            return "Anonymous AnySubscriber"
        }
        
        customMirrorThunk = {
            return Mirror(reflecting: "Anonymous AnySubscriber")
        }
        playgroundDescriptionThunk = {
            return "Anonymous AnySubscriber"
        }
    }
    
    @inlinable
    public func receive(subscription: Subscription) {
        self.box.receive(subscription: subscription)
    }
    
    @inlinable
    public func receive(_ value: Input) -> Subscribers.Demand {
        return self.box.receive(value)
    }
    
    @inlinable
    public func receive(completion: Subscribers.Completion<Failure>) {
        self.box.receive(completion: completion)
    }
}

// MARK: - Implementation

@usableFromInline
class AnySubscriberBase<Input, Failure: Error>: Subscriber {
    
    @inlinable
    init() {}
    
    @usableFromInline
    func receive(subscription: Subscription) {
        Never.requiresConcreteImplementation()
    }
    
    @usableFromInline
    func receive(_ input: Input) -> Subscribers.Demand {
        Never.requiresConcreteImplementation()
    }
    
    @usableFromInline
    func receive(completion: Subscribers.Completion<Failure>) {
        Never.requiresConcreteImplementation()
    }
}

@usableFromInline
final class AnySubscriberBox<Base: Subscriber>: AnySubscriberBase<Base.Input, Base.Failure> {
    
    @usableFromInline
    let base: Base
    
    @inlinable
    init(_ base: Base) {
        self.base = base
    }
    
    @inlinable
    override func receive(subscription: Subscription) {
        base.receive(subscription: subscription)
    }
    
    @inlinable
    override func receive(_ input: Base.Input) -> Subscribers.Demand {
        return base.receive(input)
    }
    
    @inlinable
    override func receive(completion: Subscribers.Completion<Failure>) {
        base.receive(completion: completion)
    }
}

@usableFromInline
final class ClosureBasedAnySubscriber<Input, Failure: Error>: AnySubscriberBase<Input, Failure> {
    
    @usableFromInline
    let receiveSubscriptionThunk: (Subscription) -> Void
    @usableFromInline
    let receiveValueThunk: (Input) -> Subscribers.Demand
    @usableFromInline
    let receiveCompletionThunk: (Subscribers.Completion<Failure>) -> Void
    
    @inlinable
    init(
        _ rcvSubscription: @escaping (Subscription) -> Void,
        _ rcvValue: @escaping (Input) -> Subscribers.Demand,
        _ rcvCompletion: @escaping (Subscribers.Completion<Failure>) -> Void
    ) {
        receiveSubscriptionThunk = rcvSubscription
        receiveValueThunk = rcvValue
        receiveCompletionThunk = rcvCompletion
    }
    
    @inlinable
    override func receive(subscription: Subscription) {
        receiveSubscriptionThunk(subscription)
    }
    
    @inlinable
    override func receive(_ input: Input) -> Subscribers.Demand {
        return receiveValueThunk(input)
    }
    
    @inlinable
    override func receive(completion: Subscribers.Completion<Failure>) {
        receiveCompletionThunk(completion)
    }
}

final class SubjectSubscriberBox<S: Subject>: AnySubscriberBase<S.Output, S.Failure> {
    
    let lock = Lock()
    var subject: S?
    var state: RelayState = .waiting
    
    init(_ s: S) {
        self.subject = s
    }
    
    deinit {
        lock.cleanupLock()
    }
    
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
    
    override func receive(_ input: Input) -> Subscribers.Demand {
        self.lock.lock()
        switch self.state {
        case .waiting:
            self.lock.unlock()
            APIViolation.valueBeforeSubscription()
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
    
    override func receive(completion: Subscribers.Completion<Failure>) {
        self.lock.lock()
        switch self.state {
        case .waiting:
            self.lock.unlock()
            APIViolation.unexpectedCompletion()
        case .relaying:
            self.state = .completed
            let subject = self.subject!
            self.lock.unlock()
            subject.send(completion: completion)
        case .completed:
            self.lock.unlock()
        }
    }
    
    func cancel() {
        guard let subscription = self.lock.withLockGet(self.state.complete()) else {
            return
        }
        subscription.cancel()
        self.subject = nil
    }
}
