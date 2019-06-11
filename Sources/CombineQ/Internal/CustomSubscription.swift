enum SubscriptionState {
    case waiting
    case subscribing(Subscribers.Demand)
    case completed
    case cancelled
}

class CustomSubscription<Pub, Sub>: Subscription where Pub: Publisher, Sub: Subscriber, Pub.Output == Sub.Input, Pub.Failure == Sub.Failure {
    
    typealias State = SubscriptionState
    
    let pub: Pub
    let sub: Sub
    
    let state = Atomic<State>(.waiting)
    
    init(pub: Pub, sub: Sub) {
        self.pub = pub
        self.sub = sub
    }
    
    func request(_ demand: Subscribers.Demand) {
    }
    
    func cancel() {
    }
}
