extension Subscribers {
    
    /// A signal that a publisher doesn’t produce additional elements, either due to normal completion or an error.
    ///
    /// - finished: The publisher finished normally.
    /// - failure: The publisher stopped publishing due to the indicated error.
    public enum Completion<Failure: Error> {
        
        case finished
        
        case failure(Failure)
    }
}

extension Subscribers.Completion: Equatable where Failure: Equatable {}

extension Subscribers.Completion: Hashable where Failure: Hashable {}

extension Subscribers.Completion {
    
    private enum CodingKeys: CodingKey {
        case success
        case error
    }
}

extension Subscribers.Completion: Encodable where Failure: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .finished:
            try container.encode(true, forKey: .success)
        case .failure(let e):
            try container.encode(false, forKey: .success)
            try container.encode(e, forKey: .error)
        }
    }
}

extension Subscribers.Completion: Decodable where Failure: Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try container.decode(Bool.self, forKey: .success) {
            self = .finished
        } else {
            self = .failure(try container.decode(Failure.self, forKey: .error))
        }
    }
}
