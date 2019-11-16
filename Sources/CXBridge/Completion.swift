#if canImport(Combine)

import Combine
import CombineX
import CXNamespace

// MARK: - From Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Combine.Subscribers.Completion: CXWrapping {
    
    public var cx: CombineX.Subscribers.Completion<Failure> {
        switch self {
        case .finished:             return .finished
        case let .failure(error):   return .failure(error)
        }
    }
}

// MARK: - To Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineX.Subscribers.Completion: ACWrapping {
    
    public var ac: Combine.Subscribers.Completion<Failure> {
        switch self {
        case .finished:             return .finished
        case let .failure(error):   return .failure(error)
        }
    }
}

#endif
