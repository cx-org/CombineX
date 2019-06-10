class AnySubscription: Subscription {
    
    private let anyCancellable: AnyCancellable
    private let requestDemandBody: (Subscribers.Demand) -> Void
    
    init<S: Subscription>(_ subscription: S) {
        self.anyCancellable = AnyCancellable(subscription)
        self.requestDemandBody = subscription.request(_:)
    }
    
    init(requestDemand: @escaping (Subscribers.Demand) -> Void, cancel: @escaping  () -> Void) {
        self.anyCancellable = AnyCancellable(cancel)
        self.requestDemandBody = requestDemand
    }
    
    func request(_ demand: Subscribers.Demand) {
        self.requestDemandBody(demand)
    }
    
    func cancel() {
        self.anyCancellable.cancel()
    }
}
