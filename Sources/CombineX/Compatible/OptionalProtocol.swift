public protocol OptionalProtocol {
    
    associatedtype Wrapped
    
    var optional: Wrapped? {
        set get
    }
}

extension Optional: OptionalProtocol {

    public var optional: Wrapped? {
        get { return self }
        set { self = newValue }
    }
}
