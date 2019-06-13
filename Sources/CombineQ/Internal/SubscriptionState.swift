enum SubscriptionState {
    
    // waiting for request demand
    case waiting
    
    case subscribing(Subscribers.Demand)
    
    // completed or cancelled
    case finished
}

extension SubscriptionState {
    
    var isWaiting: Bool {
        switch self {
        case .waiting:      return true
        default:            return false
        }
    }
    
    var isSubscribing: Bool {
        switch self {
        case .subscribing:  return true
        default:            return false
        }
    }
    
    var isFinished: Bool {
        switch self {
        case .finished:     return true
        default:            return false
        }
    }
}

extension SubscriptionState: Equatable {
    
    static func == (lhs: SubscriptionState, rhs: SubscriptionState) -> Bool {
        switch (lhs, rhs) {
        case (.waiting, .waiting):
            return true
        case (.subscribing(let d0), .subscribing(let d1)):
            return d0 == d1
        case (.finished, .finished):
            return true
        default:
            return false
        }
    }
}
