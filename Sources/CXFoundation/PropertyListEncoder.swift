#if !os(Linux)

import CombineX
import Foundation

extension CXWrappers {
    
    public class PropertyListEncoder: CXWrapper {
        
        public typealias Base = Foundation.PropertyListEncoder
        
        public let base: Base
        
        public init(_ base: Base) {
            self.base = base
        }
    }
}

extension PropertyListEncoder: CXWrappable {
    
    public typealias CX = CXWrappers.PropertyListEncoder
}

extension PropertyListEncoder.CX: CombineX.TopLevelEncoder {
     
    public typealias Output = Data
    
    public func encode<T>(_ value: T) throws -> Output where T : Encodable {
        return try self.base.encode(value)
    }
}

#endif
