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
    
    var demand: Subscribers.Demand? {
        guard case .subscribing(let demand) = self else {
            return nil
        }
        return demand
    }
}

extension Atomic where Value == SubscriptionState {
    
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
    
    var demand: Subscribers.Demand? {
        return self.load().demand
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

extension SubscriptionState {
    
    typealias TryAdd = (before: Subscribers.Demand, after: Subscribers.Demand)
    
    mutating func tryAdd(_ demand: Subscribers.Demand) -> TryAdd? {
        if let old = self.demand {
            let new = old + demand
            self = .subscribing(new)
            return (old, new)
        } else {
            return nil
        }
    }
    
    mutating func finishIfSubscribing() -> Bool {
        if self.isSubscribing {
            self = .finished
            return true
        }
        return false
    }
}

extension Atomic where Value == SubscriptionState {
    
    typealias TryAdd = (before: Subscribers.Demand, after: Subscribers.Demand)
    
    /// Adds the provided demand to the existing demand if the current state is `subscribing`.
    ///
    /// - Returns: `(before, after)` if added, otherwise nil.
    func tryAdd(_ demand: Subscribers.Demand) -> TryAdd? {
        return self.withLockMutating {
            if let old = $0.demand {
                let new = old + demand
                $0 = .subscribing(new)
                return (old, new)
            } else {
                return nil
            }
        }
    }

    func finishIfSubscribing() -> Bool {
        return self.withLockMutating {
            if $0.isSubscribing {
                $0 = .finished
                return true
            }
            return false
        }
    }
}
