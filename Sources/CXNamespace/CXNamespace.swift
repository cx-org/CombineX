public protocol CXWrapper {
    
    associatedtype Base
    
    var base: Base { get }
    
    init(_ base: Base)
}

public protocol CXWrappable {
    
    associatedtype CX: CXWrapper where CX.Base == Self
    
    var cx: CX { get }
}

public extension CXWrappable {
    
    var cx: CX {
        return CX(self)
    }
}

public enum CXWrappers {}

// MARK: - Compatible

public protocol CXSelfWrapping: CXWrappable, CXWrapper where Base == Self {}

public extension CXSelfWrapping {
    
    var base: Base {
        return self
    }
    
    init(_ base: Base) {
        self = base
    }
}
