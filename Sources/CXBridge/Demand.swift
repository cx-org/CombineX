import Combine
import CombineX
import CXNamespace

// MARK: - From Combine

extension Combine.Subscribers.Demand: CXWrapping {
    
    public var cx: CombineX.Subscribers.Demand {
        if let max = max {
            return .max(max)
        } else {
            return .unlimited
        }
    }
}

// MARK: - To Combine

extension CombineX.Subscribers.Demand: ACWrapping {
    
    public var ac: Combine.Subscribers.Demand {
        if let max = max {
            return .max(max)
        } else {
            return .unlimited
        }
    }
}
