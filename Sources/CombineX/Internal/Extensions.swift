// MARK: - Array
extension Array {
    
    mutating func dequeue() -> Element? {
        if self.isEmpty {
            return nil
        }
        return self.removeFirst()
    }
}

// MARK: - Result
extension Result {
    
    func tryMap<NewSuccess>(_ transform: (Success) throws -> NewSuccess) -> Result<NewSuccess, Error> {
        
        switch self {
        case .success(let success):
            do {
                let newSuccess = try transform(success)
                return .success(newSuccess)
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
