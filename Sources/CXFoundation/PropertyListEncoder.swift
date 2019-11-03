#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

import CombineX
import CXNamespace
import Foundation

extension CXWrappers {
    
    public final class PropertyListEncoder: CXWrapper {
        
        public typealias Base = Foundation.PropertyListEncoder
        
        public let base: Base
        
        public init(wrapping base: Base) {
            self.base = base
        }
    }
}

extension PropertyListEncoder: CXWrapping {
    
    public typealias CX = CXWrappers.PropertyListEncoder
}

extension PropertyListEncoder.CX: CombineX.TopLevelEncoder {
     
    public typealias Output = Data
    
    public func encode<T>(_ value: T) throws -> Output where T : Encodable {
        return try self.base.encode(value)
    }
}

#endif
