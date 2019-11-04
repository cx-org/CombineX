public final class Atom<Val> {
    
    private let lock = Lock()
    private var val: Val

    public var isMutating: Bool {
        if lock.try() {
            lock.unlock()
            return false
        }
        return true
    }
    
    public init(val: Val) {
        self.val = val
    }
    
    public func get() -> Val {
        self.lock.lock()
        defer { self.lock.unlock() }
        return self.val
    }
    
    public func set(_ new: Val) {
        self.lock.lock()
        defer { self.lock.unlock() }
        self.val = new
    }
    
    public func exchange(with new: Val) -> Val {
        self.lock.lock()
        defer { self.lock.unlock() }
        let old = self.val
        self.val = new
        return old
    }
    
    public func withLock<R>(_ body: (Val) throws -> R) rethrows -> R {
        self.lock.lock()
        defer { self.lock.unlock() }
        return try body(self.val)
    }
    
    public func withLockMutating<R>(_ body: (inout Val) throws -> R) rethrows -> R {
        self.lock.lock()
        defer { self.lock.unlock() }
        return try body(&self.val)
    }
}

public extension Atom where Val: Equatable {
    
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

public extension Atom where Val: AdditiveArithmetic {
    
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
