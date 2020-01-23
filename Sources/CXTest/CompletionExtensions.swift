import CXShim

public extension Subscribers.Completion {
    
    func mapError<NewFailure: Error>(_ transform: (Failure) -> NewFailure) -> Subscribers.Completion<NewFailure> {
        switch self {
        case .finished:
            return .finished
        case .failure(let error):
            return .failure(transform(error))
        }
    }
    
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
