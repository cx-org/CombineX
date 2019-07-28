public struct CombineXBox<Base> {
    public let base: Base
    
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol CombineXCompatible { }

extension CombineXCompatible {
    
    public var cx: CombineXBox<Self> {       
        return CombineXBox(self)
    }
}
