import CombineX
import Foundation

extension CXWrappers {
    
    public final class JSONEncoder: CXWrapper {
        
        public typealias Base = Foundation.JSONEncoder
        
        public let base: Base
        
        public init(_ base: Base) {
            self.base = base
        }
    }
}

extension JSONEncoder: CXWrappable {
    
    public typealias CX = CXWrappers.JSONEncoder
}

extension JSONEncoder.CX: CombineX.TopLevelEncoder {
        
    public typealias Output = Data
    
    public func encode<T>(_ value: T) throws -> Output where T : Encodable {
        return try self.base.encode(value)
    }
}
