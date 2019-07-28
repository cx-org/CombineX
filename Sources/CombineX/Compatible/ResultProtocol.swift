public protocol ResultProtocol {
    
    associatedtype Success
    associatedtype Failure: Error
    
    var result: Result<Success, Failure> {
        set get
    }
}

extension Result: ResultProtocol {
    
    public var result: Result {
        get { return self }
        set { self = newValue }
    }
}

extension ResultProtocol {
    
    func tryMap<NewSuccess>(_ transform: (Success) throws -> NewSuccess) -> Result<NewSuccess, Error> {
        switch self.result {
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
