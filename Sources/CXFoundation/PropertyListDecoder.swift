import CombineX
import Foundation

#if !os(Linux)
public typealias PropertyListDecoderCXWrapper = PropertyListDecoder.PropertyListDecoderCXWrapper

extension CombineXCompatible where Self: PropertyListDecoder {
    
    public var cx: PropertyListDecoderCXWrapper {
        return PropertyListDecoderCXWrapper(self)
    }
    
    public static var cx: PropertyListDecoderCXWrapper.Type {
        return PropertyListDecoderCXWrapper.self
    }
}

extension PropertyListDecoder: CombineXCompatible {
    
    public class PropertyListDecoderCXWrapper: AnyObjectCXWrapper<PropertyListDecoder>, CombineX.TopLevelDecoder {
     
        public typealias Input = Data
        
        public func decode<T>(_ type: T.Type, from: Input) throws -> T where T : Decodable {
            return try self.base.decode(type, from: from)
        }
    }
}
#endif
