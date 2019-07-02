enum RelayState_1<Pub, Sub> where Pub: Publisher, Sub: Subscriber {
    
    // waiting for subscription
    case waiting(Pub, Sub)
    
    case relaying(Pub, Sub, Subscription)
    
    case done
}

extension RelayState_1 {
    
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
        case .relaying(_, _, let s):    return s
        default:                        return nil
        }
    }
    
    var publisher: Pub? {
        switch self {
        case .waiting(let pub, _):      return pub
        case .relaying(let pub, _, _):  return pub
        default:                        return nil
        }
    }
    
    var subscriber: Sub? {
        switch self {
        case .waiting(_, let sub):      return sub
        case .relaying(_, let sub, _):  return sub
        default:                        return nil
        }
    }
    
    var pubsubIfRelaying: (Pub, Sub)? {
        switch self {
        case .relaying(let pub, let sub, _):    return (pub, sub)
        default:                                return nil
        }
    }
}

extension RelayState_1 {
    
    mutating func receive(subscription: Subscription) -> Sub? {
        switch self {
        case .waiting(let pub, let sub):
            self = .relaying(pub, sub, subscription)
            return sub
        default:
            return nil
        }
    }
    
    mutating func completeIfRelaying() -> (Pub, Sub, Subscription)? {
        switch self {
        case .relaying(let r):
            self = .done
            return r
        default:
            return nil
        }
    }
    
    mutating func complete() -> Subscription? {
        switch self {
        case .relaying(_, _, let s):
            self = .done
            return s
        case .waiting:
            self = .done
            return nil
        default:
            return nil
        }
    }
}

// MARK: - Atomic

protocol RelayState_1_Protocol {
    
    associatedtype Pub: Publisher
    associatedtype Sub: Subscriber
    
    var state: RelayState_1<Pub, Sub> {
        get set
    }
}

extension RelayState_1: RelayState_1_Protocol {
    
    var state: RelayState_1 {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}

extension Atomic where Value: RelayState_1_Protocol {
    
    var subscription: Subscription? {
        return self.withLock {
            $0.state.subscription
        }
    }
    
    var pubsubIfRelaying: (Value.Pub, Value.Sub)? {
        return self.withLock {
            $0.state.pubsubIfRelaying
        }
    }
}

extension Atomic where Value: RelayState_1_Protocol {
    
    func receive(subscription: Subscription) -> Value.Sub? {
        return self.withLockMutating {
            $0.state.receive(subscription: subscription)
        }
    }
    
    func completeIfRelaying() -> (Value.Pub, Value.Sub, Subscription)? {
        return self.withLockMutating {
            $0.state.completeIfRelaying()
        }
    }
    
    func complete() -> Subscription? {
        return self.withLockMutating {
            $0.state.complete()
        }
    }
}

