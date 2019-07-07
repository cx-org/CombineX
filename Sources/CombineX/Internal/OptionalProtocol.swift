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
    
    var isNil: Bool {
        return self.optional == nil
    }
    
    var isNotNil: Bool {
        return !self.isNil
    }
    
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

extension Atomic where Value: OptionalProtocol {
    
    var isNil: Bool {
        return self.load().optional == nil
    }
    
    var isNotNil: Bool {
        return !self.isNil
    }
    
    func ifNilStore(_ value: Value.Wrapped) -> Bool {
        return self.withLockMutating {
            $0.ifNilStore(value)
        }
    }
}

