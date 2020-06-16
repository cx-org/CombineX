#if !COCOAPODS
import CXUtility
#endif

protocol OptionalProtocol {
    
    associatedtype Wrapped
    
    var optional: Wrapped? {
        get set
    }
}

extension Optional: OptionalProtocol {

    var optional: Wrapped? {
        get { return self }
        set { self = newValue }
    }
}

extension Optional {
    
    var isNil: Bool {
        return self == nil
    }
    
    var isNotNil: Bool {
        return !self.isNil
    }
    
    mutating func setIfNil(_ value: Wrapped) -> Bool {
        switch self {
        case .none:
            self = .some(value)
            return true
        default:
            return false
        }
    }
    
    func filter(_ isIncluded: (Wrapped) -> Bool) -> Wrapped? {
        guard let val = self, isIncluded(val) else {
            return nil
        }
        return val
    }
}

extension LockedAtomic where Value: OptionalProtocol {

    var isNil: Bool {
        return self.load().optional == nil
    }

    var isNotNil: Bool {
        return !self.isNil
    }

    func setIfNil(_ value: Value.Wrapped) -> Bool {
        return self.withLockMutating {
            $0.optional.setIfNil(value)
        }
    }
}
