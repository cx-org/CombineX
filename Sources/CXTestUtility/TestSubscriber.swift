import CXShim
import CXUtility

public func makeTestSubscriber<Input, Failure: Error>(_ input: Input.Type, _ failure: Failure.Type, _ demand: Subscribers.Demand) -> TracingSubscriber<Input, Failure> {
    return TracingSubscriber<Input, Failure>(receiveSubscription: { s in
         s.request(demand)
    }, receiveValue: { _ in
        return .none
    }, receiveCompletion: { _ in
    })
}

public func makeTestSubscriber<Input, Failure: Error>(_ input: Input.Type, _ failure: Failure.Type) -> TracingSubscriber<Input, Failure> {
    return TracingSubscriber<Input, Failure>(receiveSubscription: { _ in
    }, receiveValue: { _ in
        return .none
    }, receiveCompletion: { _ in
    })
}

public extension Publisher {
    
    func subscribeTestSubscriber(initialDemand: Subscribers.Demand = .unlimited) -> TracingSubscriber<Output, Failure> {
        let sub = makeTestSubscriber(Output.self, Failure.self, initialDemand)
        subscribe(sub)
        return sub
    }
}

public extension TracingSubscriber {
    
    var eventsWithoutSubscription: [Event] {
        return self.events.filter { !$0.isSubscription }
    }
}

public extension TracingSubscriber.Event {
    
    var isSubscription: Bool {
        switch self {
        case .subscription:
            return true
        case .value, .completion:
            return false
        }
    }
}

public typealias TracingSubscriberEvent<Input, Failure: Error> = TracingSubscriber<Input, Failure>.Event

public protocol TestEventProtocol {
    associatedtype Input
    associatedtype Failure: Error
    
    var testEvent: TracingSubscriber<Input, Failure>.Event {
        get set
    }
}

extension TracingSubscriber.Event: TestEventProtocol {
    
    public var testEvent: TracingSubscriber<Input, Failure>.Event {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}

extension Collection where Element: TestEventProtocol {
    
    public func mapError<NewFailure: Error>(_ transform: (Element.Failure) -> NewFailure) -> [TracingSubscriber<Element.Input, NewFailure>.Event] {
        return self.map {
            $0.testEvent.mapError(transform)
        }
    }
}
