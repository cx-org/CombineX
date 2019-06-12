class CustomSubscription<P, S>:
    Subscription
where
    P: Publisher,
    S: Subscriber,
    P.Output == S.Input,
    P.Failure == S.Failure
{
    
    typealias State = SubscriptionState
    typealias Pub = P
    typealias Sub = S
    
    let pub: Pub
    let sub: Sub
    
    let state = Atomic<State>(value: .waiting)
    
    init(pub: Pub, sub: Sub) {
        self.pub = pub
        self.sub = sub
    }
    
    func request(_ demand: Subscribers.Demand) {
        Global.RequiresConcreteImplementation()
    }
    
    func cancel() {
        Global.RequiresConcreteImplementation()
    }
}
