import CombineX
import Foundation

#if !COCOAPODS
import CXNamespace
#endif

extension CXWrappers {
    
    public final class JSONDecoder: CXWrapper {
        
        public typealias Base = Foundation.JSONDecoder
        
        public let base: Base
        
        public init(wrapping base: Base) {
            self.base = base
        }
    }
}

extension JSONDecoder: CXWrapping {
    
    public typealias CX = CXWrappers.JSONDecoder
}

extension JSONDecoder.CX: CombineX.TopLevelDecoder {
        
    public typealias Input = Data
    
    public func decode<T>(_ type: T.Type, from: Input) throws -> T where T : Decodable {
        return try self.base.decode(type, from: from)
    }
}

