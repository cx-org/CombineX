import Combine
import CombineX

// MARK: - From Combine

extension Combine.Subscribers.Demand {
    
    public var cx: CombineX.Subscribers.Demand {
        if let max = max {
            return .max(max)
        } else {
            return .unlimited
        }
    }
}

// MARK: - To Combine

extension CombineX.Subscribers.Demand {
    
    public var combine: Combine.Subscribers.Demand {
        if let max = max {
            return .max(max)
        } else {
            return .unlimited
        }
    }
}
