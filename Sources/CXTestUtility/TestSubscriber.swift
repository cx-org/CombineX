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
