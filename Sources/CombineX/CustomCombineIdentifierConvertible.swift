public protocol CustomCombineIdentifierConvertible {
    
    var combineIdentifier: CombineIdentifier { get }
}

extension CustomCombineIdentifierConvertible where Self: AnyObject {
    
    public var combineIdentifier: CombineIdentifier {
        return CombineIdentifier(self)
    }
}
