#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

import CombineX
import Foundation

#if !COCOAPODS
import CXNamespace
#endif

extension CXWrappers {
    
    public final class PropertyListDecoder: CXWrapper {
        
        public typealias Base = Foundation.PropertyListDecoder
        
        public let base: Base
        
        public init(wrapping base: Base) {
            self.base = base
        }
    }
}

extension PropertyListDecoder: CXWrapping {
    
    public typealias CX = CXWrappers.PropertyListDecoder
}

extension PropertyListDecoder.CX: CombineX.TopLevelDecoder {
    
    public func decode<T: Decodable>(_ type: T.Type, from: Data) throws -> T {
        return try self.base.decode(type, from: from)
    }
}

#endif
