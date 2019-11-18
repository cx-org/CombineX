#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

import CombineX
import Foundation

#if !COCOAPODS
import CXNamespace
#endif

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
    
    public func encode<T: Encodable>(_ value: T) throws -> Data {
        return try self.base.encode(value)
    }
}

#endif
