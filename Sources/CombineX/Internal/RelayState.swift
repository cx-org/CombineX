enum RelayState {
    
    // waiting for subscription
    case waiting
    
    case relaying(Subscription)
    
    // completed or cancelled
    case finished
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
        case .relaying:  return true
        default:            return false
        }
    }
    
    var isFinished: Bool {
        switch self {
        case .finished:     return true
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

extension Atomic where Value == RelayState {
    
    var isWaiting: Bool {
        switch self.load() {
        case .waiting:      return true
        default:            return false
        }
    }
    
    var isRelaying: Bool {
        switch self.load() {
        case .relaying:  return true
        default:            return false
        }
    }
    
    var isFinished: Bool {
        switch self.load() {
        case .finished:     return true
        default:            return false
        }
    }
    
    var subscription: Subscription? {
        switch self.load() {
        case .relaying(let subscription):
            return subscription
        default:
            return nil
        }
    }
}

extension RelayState {
    
    mutating func finishIfRelaying() -> Subscription? {
        if let subscription = self.subscription {
            self = .finished
            return subscription
        }
        return nil
    }
}

extension Atomic where Value == RelayState {
    
    func finishIfRelaying() -> Subscription? {
        return self.withLockMutating {
            if let subscription = $0.subscription {
                $0 = .finished
                return subscription
            }
            return nil
        }
    }
}

extension RelayState: Equatable {
    
    static func == (lhs: RelayState, rhs: RelayState) -> Bool {
        switch (lhs, rhs) {
        case (.waiting, .waiting):
            return true
        case (.relaying(let d0), .relaying(let d1)):
            return (d0 as AnyObject) === (d1 as AnyObject)
        case (.finished, .finished):
            return true
        default:
            return false
        }
    }
}
