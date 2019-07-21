final class Atom<Val> {
    
    private let lock = Lock()
    
    private var val: Val
    
    init(val: Val) {
        self.val = val
    }
    
    func get() -> Val {
        self.lock.lock()
        defer { self.lock.unlock() }
        return self.val
    }
    
    func set(_ new: Val) {
        self.lock.lock()
        defer { self.lock.unlock() }
        self.val = new
    }
    
    func exchange(with new: Val) -> Val {
        self.lock.lock()
        defer { self.lock.unlock() }
        let old = self.val
        self.val = new
        return old
    }
    
    func withLock<R>(_ body: (Val) throws -> R) rethrows -> R {
        self.lock.lock()
        defer { self.lock.unlock() }
        return try body(self.val)
    }
    
    func withLockMutating<R>(_ body: (inout Val) throws -> R) rethrows -> R {
        self.lock.lock()
        defer { self.lock.unlock() }
        return try body(&self.val)
    }
}

extension Atom where Val: Equatable {
    
    func compareAndSet(expected: Val, new: Val) -> Bool {
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
