#if canImport(Foundation) && canImport(Combine)
import Foundation

#if !os(Linux)
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public typealias PropertyListEncoderCXWrapper = PropertyListEncoder.PropertyListEncoderCXWrapper

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineXCompatible where Self: PropertyListEncoder {
    
    public var cx: PropertyListEncoderCXWrapper {
        return self
    }
    
    public static var cx: PropertyListEncoderCXWrapper.Type {
        return PropertyListEncoderCXWrapper.self
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension PropertyListEncoder: CombineXCompatible {
    
    public typealias PropertyListEncoderCXWrapper = PropertyListEncoder
}
#endif

#endif
