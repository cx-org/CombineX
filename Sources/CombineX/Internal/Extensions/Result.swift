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
    
    func replaceError(with output: Success) -> Result<Success, Never> {
        switch self {
        case let .success(success):
            return .success(success)
        case .failure:
            return .success(output)
        }
    }
    
    var erasedError: Result<Success, Error> {
        switch self {
        case let .success(success):
            return .success(success)
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension Result where Failure == Never {
    
    var success: Success {
        switch self {
        case let .success(success):
            return success
        }
    }
}

extension Result where Success == Never {
    
    var error: Failure {
        switch self {
        case let .failure(error):
            return error
        }
    }
}
