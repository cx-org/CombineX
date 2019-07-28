// MARK: - Collection
extension Collection {
    
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}


// MARK: - Completion
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
