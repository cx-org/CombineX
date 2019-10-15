#if canImport(Foundation) && canImport(Combine)
import Foundation

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public typealias JSONDecoderCXWrapper = JSONDecoder.JSONDecoderCXWrapper

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineXCompatible where Self: JSONDecoder {
    
    public var cx: JSONDecoderCXWrapper {
        return self
    }
    
    public static var cx: JSONDecoderCXWrapper.Type {
        return JSONDecoderCXWrapper.self
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension JSONDecoder: CombineXCompatible {
    
    public typealias JSONDecoderCXWrapper = JSONDecoder
}

#endif
