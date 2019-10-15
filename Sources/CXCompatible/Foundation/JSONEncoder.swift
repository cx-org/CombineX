#if canImport(Foundation) && canImport(Combine)
import Foundation

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public typealias JSONEncoderCXWrapper = JSONEncoder.JSONEncoderCXWrapper

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineXCompatible where Self: JSONEncoder {
    
    public var cx: JSONEncoderCXWrapper {
        return self
    }
    
    public static var cx: JSONEncoderCXWrapper.Type {
        return JSONEncoderCXWrapper.self
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension JSONEncoder: CombineXCompatible {
    
    public typealias JSONEncoderCXWrapper = JSONEncoder
}

#endif
