public protocol CXWrapper {
    
    associatedtype Base
    
    var base: Base { get }
    
    init(wrapping base: Base)
}

public protocol CXWrapping {
    
    associatedtype CX
    
    var cx: CX { get }
}

public extension CXWrapping where CX: CXWrapper, CX.Base == Self {
    
    var cx: CX {
        return CX(wrapping: self)
    }
}

public enum CXWrappers {}

// MARK: - Compatible

// Expected Warning: Redundant conformance constraint 'Self': 'CXWrapper'
// https://bugs.swift.org/browse/SR-11670
public protocol CXSelfWrapping: CXWrapping, CXWrapper where Base == Self, CX == Self {}

public extension CXSelfWrapping {
    
    var cx: Self {
        return self
    }
    
    var base: Self {
        return self
    }
    
    init(wrapping base: Self) {
        self = base
    }
}
