import CombineX
import Foundation

#if !os(Linux)
public typealias PropertyListEncoderCXWrapper = PropertyListEncoder.PropertyListEncoderCXWrapper

extension CombineXCompatible where Self: PropertyListEncoder {
    
    public var cx: PropertyListEncoderCXWrapper {
        return PropertyListEncoderCXWrapper(self)
    }
    
    public static var cx: PropertyListEncoderCXWrapper.Type {
        return PropertyListEncoderCXWrapper.self
    }
}

extension PropertyListEncoder: CombineXCompatible {
    
    public class PropertyListEncoderCXWrapper: AnyObjectCXWrapper<PropertyListEncoder>, CombineX.TopLevelEncoder {
     
        public typealias Output = Data
        
        public func encode<T>(_ value: T) throws -> Output where T : Encodable {
            return try self.base.encode(value)
        }
    }
}
#endif
