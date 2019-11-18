import CombineX
import Foundation

#if !COCOAPODS
import CXNamespace
#endif

extension CXWrappers {
    
    public final class JSONEncoder: CXWrapper {
        
        public typealias Base = Foundation.JSONEncoder
        
        public let base: Base
        
        public init(wrapping base: Base) {
            self.base = base
        }
    }
}

extension JSONEncoder: CXWrapping {
    
    public typealias CX = CXWrappers.JSONEncoder
}

extension JSONEncoder.CX: CombineX.TopLevelEncoder {
    
    public func encode<T: Encodable>(_ value: T) throws -> Data {
        return try self.base.encode(value)
    }
}
