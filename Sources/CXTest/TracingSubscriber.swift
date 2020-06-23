import CXShim
import CXUtility

public class TracingSubscriber<Input, Failure: Error>: Subscriber {
    
    public enum Event {
        case subscription(CombineIdentifier)
        case value(Input)
        case completion(Subscribers.Completion<Failure>)
    }
    
    private let _rcvSubscription: ((Subscription) -> Void)?
    private let _rcvValue: ((Input) -> Subscribers.Demand)?
    private let _rcvCompletion: ((Subscribers.Completion<Failure>) -> Void)?
    
    private let _lock = Lock()
    private var _subscription: Subscription?
    private var _events: [Event] = []
    
    public var events: [Event] {
        return self._lock.withLockGet(self._events)
    }
    
    public var subscription: Subscription? {
        return self._lock.withLockGet(self._subscription)
    }
    
    public init(receiveSubscription: ((Subscription) -> Void)? = nil, receiveValue: ((Input) -> Subscribers.Demand)? = nil, receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil) {
        self._rcvSubscription = receiveSubscription
        self._rcvValue = receiveValue
        self._rcvCompletion = receiveCompletion
    }
    
    deinit {
        _lock.cleanupLock()
    }
    
    public func receive(subscription: Subscription) {
        self._lock.withLock {
            self._events.append(.subscription(subscription.combineIdentifier))
            self._subscription = subscription
        }
        self._rcvSubscription?(subscription)
    }
    
    public func receive(_ value: Input) -> Subscribers.Demand {
        self._lock.withLock {
            self._events.append(.value(value))
        }
        return self._rcvValue?(value) ?? .none
    }
    
    public func receive(completion: Subscribers.Completion<Failure>) {
        self._lock.withLock {
            self._events.append(.completion(completion))
            self._subscription = nil
        }
        self._rcvCompletion?(completion)
    }
    
    public func releaseSubscription() {
        self._lock.withLock {
            self._subscription = nil
        }
    }
}

extension TracingSubscriber: CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible {
    
    public var description: String {
        return "\(type(of: self))"
    }
    
    public var playgroundDescription: Any {
        return description
    }
    
    public var customMirror: Mirror {
        return Mirror(self, children: [
            "_rcvSubscription": _rcvSubscription as Any,
            "_rcvValue": _rcvValue as Any,
            "_rcvCompletion": _rcvCompletion as Any,
            "_lock": _lock,
            "_subscription": _subscription as Any,
            "_events": _events,
        ])
    }
}

// MARK: - Event

extension TracingSubscriber.Event: Equatable where Input: Equatable, Failure: Equatable {}

extension TracingSubscriber.Event: Hashable where Input: Hashable, Failure: Hashable {}

extension TracingSubscriber.Event: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case let .subscription(s):
            return "subscription \(s)"
        case let .value(v):
            return "value \(v)"
        case let .completion(c):
            return "completion \(c)"
        }
    }
}

public extension TracingSubscriber.Event {
    
    var value: Input? {
        switch self {
        case .value(let v):
            return v
        case .subscription, .completion:
            return nil
        }
    }
    
    var completion: Subscribers.Completion<Failure>? {
        switch self {
        case let .completion(c):
            return c
        case .subscription, .value:
            return nil
        }
    }
    
    func mapError<NewFailure: Error>(_ transform: (Failure) -> NewFailure) -> TracingSubscriber<Input, NewFailure>.Event {
        switch self {
        case let .subscription(s):
            return .subscription(s)
        case let .value(i):
            return .value(i)
        case let .completion(c):
            return .completion(c.mapError(transform))
        }
    }
}
