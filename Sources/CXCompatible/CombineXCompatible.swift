@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol CombineXWrapper {
    associatedtype Base
    var base: Base { get }
    init(_ base: Base)
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AnyCXWrapper<Base>: CombineXWrapper {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol CombineXCompatible {
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineXCompatible {
    
    public var cx: AnyCXWrapper<Self> {
        return AnyCXWrapper(self)
    }
    
    public static var cx: AnyCXWrapper<Self>.Type {
        return AnyCXWrapper.self
    }
}

