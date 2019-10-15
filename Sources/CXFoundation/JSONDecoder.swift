import CombineX
import Foundation

public typealias JSONDecoderCXWrapper = JSONDecoder.JSONDecoderCXWrapper

extension CombineXCompatible where Self: JSONDecoder {
    
    public var cx: JSONDecoderCXWrapper {
        return JSONDecoderCXWrapper(self)
    }
    
    public static var cx: JSONDecoderCXWrapper.Type {
        return JSONDecoderCXWrapper.self
    }
}

extension JSONDecoder: CombineXCompatible {
    
    public class JSONDecoderCXWrapper: AnyObjectCXWrapper<JSONDecoder>, CombineX.TopLevelDecoder {
        
        public typealias Input = Data
        
        public func decode<T>(_ type: T.Type, from: Input) throws -> T where T : Decodable {
            return try self.base.decode(type, from: from)
        }
    }
}

