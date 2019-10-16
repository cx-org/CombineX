import CombineX
import Foundation

extension CXWrappers {
    
    open class JSONEncoder: CXWrapper {
        
        public typealias Base = Foundation.JSONEncoder
        
        public var base: Base
        
        public required init(_ base: Base) {
            self.base = base
        }
    }
}

extension JSONEncoder: CXCompatible {
    
    public typealias CX = CXWrappers.JSONEncoder
}

extension JSONEncoder.CX: CombineX.TopLevelEncoder {
        
    public typealias Output = Data
    
    public func encode<T>(_ value: T) throws -> Output where T : Encodable {
        return try self.base.encode(value)
    }
}
