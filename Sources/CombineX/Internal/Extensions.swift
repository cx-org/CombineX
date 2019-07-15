// MARK: - Collection
extension Collection {
    
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}

// MARK: - Result
extension Result {
    
    func tryMap<NewSuccess>(_ transform: (Success) throws -> NewSuccess) -> Result<NewSuccess, Error> {
        switch self {
        case .success(let success):
            do {
                return .success(try transform(success))
            } catch {
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}

// MARK: - Completion
extension Subscribers.Completion {
    
    func mapError<NewFailure>(_ transform: (Failure) -> NewFailure) -> Subscribers.Completion<NewFailure> {
        switch self {
        case .finished:
            return .finished
        case .failure(let error):
            return .failure(transform(error))
        }
    }
}
