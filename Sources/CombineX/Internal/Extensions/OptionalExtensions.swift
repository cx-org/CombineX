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
    
    func filter(_ isIncluded: (Wrapped) -> Bool) -> Wrapped? {
        guard let val = self, isIncluded(val) else {
            return nil
        }
        return val
    }
}

extension LockedAtomic where Value: OptionalProtocol {
    
    func setIfNil(_ value: Value.Wrapped) -> Bool {
        return self.withLockMutating {
            if $0.optional == nil {
                $0.optional = value
                return true
            } else {
                return false
            }
        }
    }
}
