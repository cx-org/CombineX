enum RelayState {
    
    // waiting for subscription
    case waiting
    
    case relaying(Subscription)
    
    // completed or cancelled
    case done
}

extension RelayState {
    
    var isWaiting: Bool {
        switch self {
        case .waiting:      return true
        default:            return false
        }
    }
    
    var isRelaying: Bool {
        switch self {
        case .relaying:     return true
        default:            return false
        }
    }
    
    var isDone: Bool {
        switch self {
        case .done:         return true
        default:            return false
        }
    }
    
    var subscription: Subscription? {
        switch self {
        case .relaying(let subscription):
            return subscription
        default:
            return nil
        }
    }
}

// MARK: - Transit

extension RelayState {
    
    mutating func relay(_ subscription: Subscription) -> Bool {
        if self.isWaiting {
            self = .relaying(subscription)
            return true
        }
        return false
    }
    
    mutating func done() -> Subscription? {
        defer {
            self = .done
        }
        return self.subscription
    }
}

extension RelayState: Equatable {
    
    static func == (lhs: RelayState, rhs: RelayState) -> Bool {
        switch (lhs, rhs) {
        case (.waiting, .waiting):
            return true
        case (.relaying(let a), .relaying(let b)):
            return (a as AnyObject) === (b as AnyObject)
        case (.done, .done):
            return true
        default:
            return false
        }
    }
}
