@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol ACWrapper {
    
    associatedtype Base
    
    var base: Base { get }
    
    init(wrapping base: Base)
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol ACWrapping {
    
    associatedtype AC
    
    var ac: AC { get }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension ACWrapping where AC: ACWrapper, AC.Base == Self {
    
    var ac: AC {
        return AC(wrapping: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public enum ACWrappers {}
