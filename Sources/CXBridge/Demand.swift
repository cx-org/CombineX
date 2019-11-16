#if canImport(Combine)

import Combine
import CombineX
import CXNamespace

// MARK: - From Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
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

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineX.Subscribers.Demand: ACWrapping {
    
    public var ac: Combine.Subscribers.Demand {
        if let max = max {
            return .max(max)
        } else {
            return .unlimited
        }
    }
}

#endif
