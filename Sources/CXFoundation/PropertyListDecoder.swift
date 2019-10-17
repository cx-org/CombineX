#if !os(Linux)

import CombineX
import Foundation

extension CXWrappers {
    
    open class PropertyListDecoder: CXWrapper {
        
        public typealias Base = Foundation.PropertyListDecoder
        
        public var base: Base
        
        public required init(_ base: Base) {
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
