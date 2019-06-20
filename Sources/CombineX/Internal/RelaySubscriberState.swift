enum RelaySubscriberState {
    
    // waiting for subscription
    case waiting
    
    case subscribing(Subscription)
    
    // completed or cancelled
    case finished
}

extension RelaySubscriberState {
    
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
    
    var subscription: Subscription? {
        switch self {
        case .subscribing(let subscription):
            return subscription
        default:
            return nil
        }
    }
}

extension RelaySubscriberState: Equatable {
    
    static func == (lhs: RelaySubscriberState, rhs: RelaySubscriberState) -> Bool {
        switch (lhs, rhs) {
        case (.waiting, .waiting):
            return true
        case (.subscribing(let d0), .subscribing(let d1)):
            return (d0 as AnyObject) === (d1 as AnyObject)
        case (.finished, .finished):
            return true
        default:
            return false
        }
    }
}

extension Atomic where Value == RelaySubscriberState {
    
    var isWaiting: Bool {
        switch self.load() {
        case .waiting:      return true
        default:            return false
        }
    }
    
    var isSubscribing: Bool {
        switch self.load() {
        case .subscribing:  return true
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
        case .subscribing(let subscription):
            return subscription
        default:
            return nil
        }
    }
}

extension Atomic where Value == RelaySubscriberState {
    
    func finishIfSubscribing() -> Subscription? {
        return self.withLockMutating {
            if let subscription = $0.subscription {
                $0 = .finished
                return subscription
            }
            return nil
        }
    }
}
