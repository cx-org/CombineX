import CombineX
import Foundation

public typealias JSONEncoderCXWrapper = JSONEncoder.JSONEncoderCXWrapper

extension CombineXCompatible where Self: JSONEncoder {
    
    public var cx: JSONEncoderCXWrapper {
        return JSONEncoderCXWrapper(self)
    }
    
    public static var cx: JSONEncoderCXWrapper.Type {
        return JSONEncoderCXWrapper.self
    }
}

extension JSONEncoder: CombineXCompatible {
    
    public class JSONEncoderCXWrapper: AnyObjectCXWrapper<JSONEncoder>, CombineX.TopLevelEncoder {
        
        public typealias Output = Data
        
        public func encode<T>(_ value: T) throws -> Output where T : Encodable {
            return try self.base.encode(value)
        }
    }
}
