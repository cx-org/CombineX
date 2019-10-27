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

// Expected Warning: Redundant conformance constraint 'Self': 'CXWrapper'
// https://bugs.swift.org/browse/SR-11670
public protocol CXSelfWrapping: CXWrappable, CXWrapper where Base == Self, CX == Self {}

public extension CXSelfWrapping {
    
    var cx: Self {
        return self
    }
    
    var base: Self {
        return self
    }
    
    init(_ base: Self) {
        self = base
    }
}
