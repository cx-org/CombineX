public protocol CombineXWrapper {
    associatedtype Base
    var base: Base { get }
    init(_ base: Base)
}

public struct AnyCXWrapper<Base>: CombineXWrapper {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol CombineXCompatible {
}

extension CombineXCompatible {
    
    public var cx: AnyCXWrapper<Self> {
        return AnyCXWrapper(self)
    }
    
    public static var cx: AnyCXWrapper<Self>.Type {
        return AnyCXWrapper.self
    }
}

