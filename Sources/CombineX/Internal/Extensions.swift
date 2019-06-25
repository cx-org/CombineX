// MARK: - Array
extension Array {
    
    mutating func tryRemoveFirst() -> Element? {
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
