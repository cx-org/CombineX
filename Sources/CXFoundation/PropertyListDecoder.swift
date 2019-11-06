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
     
    public typealias Input = Data
    
    public func decode<T>(_ type: T.Type, from: Input) throws -> T where T : Decodable {
        return try self.base.decode(type, from: from)
    }
}

#endif
