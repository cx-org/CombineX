final class Atom<Val> {

    private let lock = Lock()
    private var val: Val
    
    init(val: Val) {
        self.val = val
    }
    
    func get() -> Val {
        return self.lock.withLockGet(self.val)
    }
    
    func set(_ new: Val) {
        self.lock.withLock {
            self.val = new
        }
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
        self.lock.lock()
        defer { self.lock.unlock() }
        
        if self.val == expected {
            self.val = new
            return true
        }
        
        return false
    }
}

extension Atom where Val: AdditiveArithmetic {
    
    func add(_ val: Val) -> Val {
        self.lock.lock()
        defer { self.lock.unlock() }
        
        let old = self.val
        self.val += val
        return old
    }
    
    func sub(_ val: Val) -> Val {
        self.lock.lock()
        defer { self.lock.unlock() }
        
        let old = self.val
        self.val -= val
        return old
    }
}
