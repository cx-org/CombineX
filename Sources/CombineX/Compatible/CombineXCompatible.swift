public protocol CombineXWrapper {
    associatedtype Base
    var base: Base { get }
    init(_ base: Base)
}

public struct AnyCombineXWrapper<Base>: CombineXWrapper {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol CombineXCompatible {
    
    associatedtype CXWrapper where CXWrapper: CombineXWrapper, CXWrapper.Base == Self
}

extension CombineXCompatible {
    
    public var cx: CXWrapper {
        return CXWrapper(self)
    }
    
    public static var cx: CXWrapper.Type {
        return CXWrapper.self
    }
}

