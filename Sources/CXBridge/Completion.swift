import Combine
import CombineX

// MARK: - From Combine

extension Combine.Subscribers.Completion {
    
    public var cx: CombineX.Subscribers.Completion<Failure> {
        switch self {
        case .finished:             return .finished
        case let .failure(error):   return .failure(error)
        }
    }
}

// MARK: - To Combine

extension CombineX.Subscribers.Completion {
    
    public var combine: Combine.Subscribers.Completion<Failure> {
        switch self {
        case .finished:             return .finished
        case let .failure(error):   return .failure(error)
        }
    }
}
