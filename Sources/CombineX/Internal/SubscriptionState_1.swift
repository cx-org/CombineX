enum SubscriptionState_1<Sub: Subscriber> {
    
    // waiting for request demand
    case waiting(Sub)
    
    case subscribing(Sub, Subscribers.Demand)
    
    // completed or cancelled
    case done
}

// MARK: Properties
extension SubscriptionState_1 {
    
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
    
    var isDone: Bool {
        switch self {
        case .done:         return true
        default:            return false
        }
    }
    
    var demand: Subscribers.Demand? {
        switch self {
        case .subscribing(_, let d):    return d
        default:                        return nil
        }
    }
    
    var subscriber: Sub? {
        switch self {
        case .waiting(let s):           return s
        case .subscribing(let s, _):    return s
        default:                        return nil
        }
    }
}

// MARK: Transition
extension SubscriptionState_1 {
    
    mutating func requestIfWaiting(_ demand: Subscribers.Demand) -> Sub? {
        switch self {
        case .waiting(let s):
            self = .subscribing(s, demand)
            return s
        default:
            return nil
        }
    }
    
    mutating func request(_ demand: Subscribers.Demand) -> (Sub, Subscribers.Demand)? {
        switch self {
        case .waiting(let s):
            self = .subscribing(s, demand)
            return (s, demand)
        case .subscribing(let s, let d):
            let after = d + demand
            self = .subscribing(s, after)
            return (s, after)
        default:
            return nil
        }
    }
}


protocol SubscriptionState_1_Protocol {
    
    associatedtype Sub: Subscriber
    
    var state: SubscriptionState_1<Sub> {
        get set
    }
}

extension SubscriptionState_1: SubscriptionState_1_Protocol {
    
    var state: SubscriptionState_1 {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}

extension Atomic where Value: SubscriptionState_1_Protocol {
    
    func requestIfWaiting(_ demand: Subscribers.Demand) -> Value.Sub? {
        return self.withLockMutating {
            $0.state.requestIfWaiting(demand)
        }
    }

    func request(_ demand: Subscribers.Demand) -> (Value.Sub, Subscribers.Demand)? {
        return self.withLockMutating {
            $0.state.request(demand)
        }
    }
}
