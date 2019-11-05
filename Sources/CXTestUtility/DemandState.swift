import CXShim

public enum DemandState {
    
    case waiting
    
    case demanding(Subscribers.Demand)
    
    case completed
}

public extension DemandState {
    
    var isWaiting: Bool {
        switch self {
        case .waiting:          return true
        default:                return false
        }
    }
    
    var isDemanding: Bool {
        switch self {
        case .demanding:      return true
        default:                return false
        }
    }
    
    var isCompleted: Bool {
        switch self {
        case .completed:        return true
        default:                return false
        }
    }
    
    var demand: Subscribers.Demand? {
        switch self {
        case .demanding(let d):   return d
        default:                    return nil
        }
    }
}

public extension DemandState {
    
    /// - Returns: `true` if the previous state is not `completed`.
    mutating func complete() -> Bool {
        defer {
            self = .completed
        }
        return !self.isCompleted
    }
}

public extension DemandState {
    
    typealias Demands = (old: Subscribers.Demand, new: Subscribers.Demand)
    
    mutating func add(_ demand: Subscribers.Demand) -> Demands? {
        guard let old = self.demand else {
            return nil
        }
        let new = old + demand
        self = .demanding(new)
        return (old, new)
    }
    
    mutating func sub(_ demand: Subscribers.Demand) -> Demands? {
        guard let old = self.demand else {
            return nil
        }
        let new = old - demand
        self = .demanding(new)
        return (old, new)
    }
}

