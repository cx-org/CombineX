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
        return self.withLock {
            $0.isWaiting
        }
    }
    
    var isSubscribing: Bool {
        return self.withLock {
            $0.isSubscribing
        }    }
    
    var isFinished: Bool {
        return self.withLock {
            $0.isFinished
        }
    }
    
    var demand: Subscribers.Demand? {
        return self.withLock {
            $0.demand
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

extension SubscriptionState {
    
    typealias Demands = (before: Subscribers.Demand, after: Subscribers.Demand)
    
    mutating func addIfSubscribing(_ demand: Int) -> Demands? {
        if let old = self.demand {
            let new = old + demand
            self = .subscribing(new)
            return (old, new)
        } else {
            return nil
        }
    }
    
    mutating func addIfSubscribing(_ demand: Subscribers.Demand) -> Demands? {
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
    
    typealias Demands = (before: Subscribers.Demand, after: Subscribers.Demand)
    
    func addIfSubscribing(_ demand: Int) -> Demands? {
        return self.withLockMutating {
            $0.addIfSubscribing(demand)
        }
    }
    
    /// Adds the provided demand to the existing demand if the current state is `subscribing`.
    ///
    /// - Returns: `(before, after)` if added, otherwise nil.
    func addIfSubscribing(_ demand: Subscribers.Demand) -> Demands? {
        return self.withLockMutating {
            $0.addIfSubscribing(demand)
        }
    }

    func finishIfSubscribing() -> Bool {
        return self.withLockMutating {
            $0.finishIfSubscribing()
        }
    }
}
