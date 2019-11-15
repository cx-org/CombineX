protocol ACWrapper {
    
    associatedtype Base
    
    var base: Base { get }
    
    init(wrapping base: Base)
}

protocol ACWrapping {
    
    associatedtype AC
    
    var ac: AC { get }
}

extension ACWrapping where AC: ACWrapper, AC.Base == Self {
    
    var ac: AC {
        return AC(wrapping: self)
    }
}

public enum ACWrappers {}
