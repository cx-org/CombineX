enum RelayState {
    
    case waiting
    
    case relaying(Subscription)
    
    case completed
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
    
    var isCompleted: Bool {
        switch self {
        case .completed:         return true
        default:            return false
        }
    }
    
    var subscription: Subscription? {
        switch self {
        case .relaying(let s):  return s
        default:                return nil
        }
    }
}

// MARK: - Transit

extension RelayState {
    
    mutating func relay(_ subscription: Subscription) -> Bool {
        guard self.isWaiting else { return false }
        self = .relaying(subscription)
        return true
    }
    
    
    mutating func complete() -> Subscription? {
        defer {
            self = .completed
        }
        return self.subscription
    }
}
