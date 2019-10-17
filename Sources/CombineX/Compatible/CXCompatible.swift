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
