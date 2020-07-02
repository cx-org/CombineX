import CXShim
import CXUtility

extension Publisher {
    
    public func subscribeTracingSubscriber(initialDemand: Subscribers.Demand?, subsequentDemand: ((Output) -> Subscribers.Demand)? = nil) -> TracingSubscriber<Output, Failure> {
        let sub = TracingSubscriber<Output, Failure>(receiveSubscription: { s in
            initialDemand.map(s.request)
        }, receiveValue: { v in
            return subsequentDemand?(v) ?? .none
        })
        subscribe(sub)
        return sub
    }
    
    public func subscribeTracingSubscriber(initialDemand: Subscribers.Demand?, subsequentDemand: @autoclosure @escaping () -> Subscribers.Demand) -> TracingSubscriber<Output, Failure> {
        let sub = TracingSubscriber<Output, Failure>(receiveSubscription: { s in
            initialDemand.map(s.request)
        }, receiveValue: { _ in
            return subsequentDemand()
        })
        subscribe(sub)
        return sub
    }
}

extension TracingSubscriber {
    
    public var eventsWithoutSubscription: [Event] {
        return self.events.filter { !$0.isSubscription }
    }
}

extension TracingSubscriber.Event {
    
    public var isSubscription: Bool {
        switch self {
        case .subscription:
            return true
        case .value, .completion:
            return false
        }
    }
}

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
