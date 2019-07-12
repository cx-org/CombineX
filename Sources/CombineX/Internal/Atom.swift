final class Atom<Val> {
    
    private let lock = Lock()
    
    private var val: Val
    
    init(_ val: Val) {
        self.val = val
    }
    
    func get() -> Val {
        self.lock.lock(); defer { self.lock.unlock() }
        return self.val
    }
    
    func set(_ val: Val) {
        self.lock.lock(); defer { self.lock.unlock() }
        self.val = val
    }
    
    /// Stores the provided value.
    ///
    /// - Returns: The old value.
    func exchange(with value: Val) -> Val {
        lock.lock(); defer { lock.unlock() }
        let old = self.val
        self.val = value
        return old
    }
    
    func withLock<Result>(_ body: (Val) throws -> Result) rethrows -> Result {
        lock.lock(); defer { lock.unlock() }
        return try body(self.val)
    }
    
    func withLockMutating<Result>(_ body: (inout Val) throws -> Result) rethrows -> Result {
        lock.lock(); defer { lock.unlock() }
        return try body(&self.val)
    }
}

extension Atom where Val: Equatable {
    
    func compareAndStore(expected: Val, new: Val) -> Bool {
        return self.withLockMutating {
            if $0 == expected {
                $0 = new
                return true
            }
            return false
        }
    }
}

extension Atom where Val: AdditiveArithmetic {
    
    func add(_ val: Val) -> Val {
        return self.withLockMutating {
            let old = $0
            $0 += val
            return old
        }
    }
    
    func sub(_ val: Val) -> Val {
        return self.withLockMutating {
            let old = $0
            $0 -= val
            return old
        }
    }
}

// MARK: Demands
extension Atom where Val == Subscribers.Demand {

    func add(_ val: Val) -> Val {
        return self.withLockMutating {
            let old = $0
            $0 += val
            return old
        }
    }
    
    func sub(_ val: Val) -> Val {
        return self.withLockMutating {
            let old = $0
            $0 -= val
            return old
        }
    }
}
