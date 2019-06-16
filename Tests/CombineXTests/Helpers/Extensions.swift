@testable import CombineX

// MARK: - Subscribers.Completion

extension Subscribers.Completion {
    
    var isFinished: Bool {
        switch self {
        case .finished:
            return true
        case .failure:
            return false
        }
    }
    
    var isFailure: Bool {
        switch self {
        case .failure:
            return true
        case .finished:
            return false
        }
    }
}
