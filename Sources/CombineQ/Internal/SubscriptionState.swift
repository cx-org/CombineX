enum SubscriptionState {
    case waiting
    case subscribing(Subscribers.Demand)
    case completed
    case cancelled
}
