import Combine
import CombineX

// MARK: - From Combine

extension Combine.Subscription {
    
    var cx: AnyCombineSubscription {
        return AnyCombineSubscription(subscription: self)
    }
}

struct AnyCombineSubscription: CombineX.Subscription {
    
    public var subscription: Combine.Subscription
    
    public func request(_ demand: CombineX.Subscribers.Demand) {
        subscription.request(demand.combine)
    }
    
    public func cancel() {
        subscription.cancel()
    }
    
    public var combineIdentifier: CombineX.CombineIdentifier {
        return subscription.combineIdentifier.cx
    }
}

// MARK: - To Combine

extension CombineX.Subscription {
    
    var combine: AnyCXSubscription {
        return AnyCXSubscription(subscription: self)
    }
}

struct AnyCXSubscription: Combine.Subscription {
    
    public var subscription: CombineX.Subscription
    
    public func request(_ demand: Combine.Subscribers.Demand) {
        subscription.request(demand.cx)
    }
    
    public func cancel() {
        subscription.cancel()
    }
    
    public var combineIdentifier: Combine.CombineIdentifier {
        return subscription.combineIdentifier.combine
    }
}
