protocol OptionalProtocol {
    
    associatedtype Wrapped
    
    var optional: Optional<Wrapped> {
        set get
    }
}

extension Optional: OptionalProtocol {

    var optional: Optional<Wrapped> {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}

extension OptionalProtocol {
    
    mutating func ifNilStore(_ value: Wrapped) -> Bool {
        switch self.optional {
        case .none:
            self.optional = .some(value)
            return true
        default:
            return false
        }
    }
}
