#if USE_COMBINE
import Combine
#else
import CombineX
#endif

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

// MARK: - Int
extension Int {
    
    func times(_ body: (Int) -> Void) {
        guard self > 0 else {
            return
        }
        for i in 0..<self {
            body(i)
        }
    }
    
    func times(_ body: () -> Void) {
        self.times { (_) in
            body()
        }
    }
}
