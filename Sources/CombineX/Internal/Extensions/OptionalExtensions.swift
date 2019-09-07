extension OptionalProtocol {
    
    var isNil: Bool {
        return self.optional == nil
    }
    
    var isNotNil: Bool {
        return !self.isNil
    }
    
    mutating func setIfNil(_ value: Wrapped) -> Bool {
        switch self.optional {
        case .none:
            self.optional = .some(value)
            return true
        default:
            return false
        }
    }
}

extension Atom where Val: OptionalProtocol {

    var isNil: Bool {
        return self.get().optional == nil
    }

    var isNotNil: Bool {
        return !self.isNil
    }

    func setIfNil(_ value: Val.Wrapped) -> Bool {
        return self.withLockMutating {
            $0.setIfNil(value)
        }
    }
}

extension OptionalProtocol where Wrapped: OptionalProtocol {
    
    func unwrap() -> Wrapped.Wrapped? {
        return self.optional?.optional ?? nil
    }
}
