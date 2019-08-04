#if USE_COMBINE
import Combine
#else
import CombineX
#endif

extension Subscribers.Completion {
    
    func mapError<NewFailure: Error>(_ transform: (Failure) -> NewFailure) -> Subscribers.Completion<NewFailure> {
        switch self {
        case .finished:
            return .finished
        case .failure(let error):
            return .failure(transform(error))
        }
    }
}

