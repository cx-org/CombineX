#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

import CombineX
import CXNamespace
import Foundation

extension CXWrappers {
    
    public final class PropertyListDecoder: CXWrapper {
        
        public typealias Base = Foundation.PropertyListDecoder
        
        public let base: Base
        
        public init(_ base: Base) {
            self.base = base
        }
    }
}

extension PropertyListDecoder: CXWrappable {
    
    public typealias CX = CXWrappers.PropertyListDecoder
}

extension PropertyListDecoder.CX: CombineX.TopLevelDecoder {
     
    public typealias Input = Data
    
    public func decode<T>(_ type: T.Type, from: Input) throws -> T where T : Decodable {
        return try self.base.decode(type, from: from)
    }
}

#endif
