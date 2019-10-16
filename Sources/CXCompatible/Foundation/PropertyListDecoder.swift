#if canImport(Foundation) && canImport(Combine)
import Foundation

#if !os(Linux)
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public typealias PropertyListDecoderCXWrapper = PropertyListDecoder.PropertyListDecoderCXWrapper

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineXCompatible where Self: PropertyListDecoder {
    
    public var cx: PropertyListDecoderCXWrapper {
        return self
    }
    
    public static var cx: PropertyListDecoderCXWrapper.Type {
        return PropertyListDecoderCXWrapper.self
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension PropertyListDecoder: CombineXCompatible {
    
    public typealias PropertyListDecoderCXWrapper = PropertyListDecoder
}
#endif

#endif
