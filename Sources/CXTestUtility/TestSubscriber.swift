import CXShim
import CXUtility

public extension Publisher {
    
    func subscribeTracingSubscriber(initialDemand: Subscribers.Demand? = nil, subsequentDemand: ((Output) -> Demand)? = nil) -> TracingSubscriber<Output, Failure> {
        let sub = TracingSubscriber<Output, Failure>(receiveSubscription: { s in
            initialDemand.map(s.request)
        }, receiveValue: { v -> Subscribers.Demand in
            return subsequentDemand?(v) ?? .none
        })
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
