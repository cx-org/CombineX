public protocol ACWrapper {
    
    associatedtype Base
    
    var base: Base { get }
    
    init(wrapping base: Base)
}

public protocol ACWrapping {
    
    associatedtype AC
    
    var ac: AC { get }
}

public extension ACWrapping where AC: ACWrapper, AC.Base == Self {
    
    var ac: AC {
        return AC(wrapping: self)
    }
}

public enum ACWrappers {}
