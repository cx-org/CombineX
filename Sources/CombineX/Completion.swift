extension Subscribers {
    
    /// A signal that a publisher doesn’t produce additional elements, either due to normal completion or an error.
    ///
    /// - finished: The publisher finished normally.
    /// - failure: The publisher stopped publishing due to the indicated error.
    public enum Completion<Failure> where Failure : Error {
        
        case finished
        
        case failure(Failure)
    }
}

extension Subscribers.Completion : Equatable where Failure : Equatable {
    
    public static func == (a: Subscribers.Completion<Failure>, b: Subscribers.Completion<Failure>) -> Bool {
        switch (a, b) {
        case (.finished, .finished):
            return true
        case (.failure(let e0), .failure(let e1)):
            return e0 == e1
        default:
            return false
        }
    }
}

extension Subscribers.Completion : Hashable where Failure : Hashable {
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .failure(let e):
            hasher.combine(e)
        case .finished:
            break
        }
    }
}

extension Subscribers.Completion {
    
    private enum CodingKeys: CodingKey {
        case success
        case error
    }
}

extension Subscribers.Completion : Encodable where Failure : Encodable {
    
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

extension Subscribers.Completion : Decodable where Failure : Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try container.decode(Bool.self, forKey: .success) {
            self = .finished
        } else {
            self = .failure(try container.decode(Failure.self, forKey: .error))
        }
    }
}
