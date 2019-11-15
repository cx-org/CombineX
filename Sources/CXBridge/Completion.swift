import Combine
import CombineX
import CXNamespace

// MARK: - From Combine

extension Combine.Subscribers.Completion: CXWrapping {
    
    public var cx: CombineX.Subscribers.Completion<Failure> {
        switch self {
        case .finished:             return .finished
        case let .failure(error):   return .failure(error)
        }
    }
}

// MARK: - To Combine

extension CombineX.Subscribers.Completion: ACWrapping {
    
    public var ac: Combine.Subscribers.Completion<Failure> {
        switch self {
        case .finished:             return .finished
        case let .failure(error):   return .failure(error)
        }
    }
}
