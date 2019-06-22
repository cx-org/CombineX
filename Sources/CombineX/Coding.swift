public protocol TopLevelDecoder {
    
    associatedtype Input
    
    func decode<T>(_ type: T.Type, from: Self.Input) throws -> T where T : Decodable
}

public protocol TopLevelEncoder {
    
    associatedtype Output
    
    func encode<T>(_ value: T) throws -> Self.Output where T : Encodable
}
