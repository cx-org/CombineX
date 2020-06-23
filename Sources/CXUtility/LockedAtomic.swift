public final class LockedAtomic<Value> {
    
    private let lock = Lock()
    private var value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
    
    deinit {
        lock.cleanupLock()
    }
    
    public var isMutating: Bool {
        if lock.tryLock() {
            lock.unlock()
            return false
        }
        return true
    }
    
    public func load() -> Value {
        self.lock.lock()
        defer { self.lock.unlock() }
        return self.value
    }
    
    public func store(_ desired: Value) {
        self.lock.lock()
        defer { self.lock.unlock() }
        self.value = desired
    }
    
    public func exchange(_ desired: Value) -> Value {
        self.lock.lock()
        defer { self.lock.unlock() }
        let old = self.value
        self.value = desired
        return old
    }
    
    public func withLockMutating<R>(_ body: (inout Value) throws -> R) rethrows -> R {
        self.lock.lock()
        defer { self.lock.unlock() }
        return try body(&self.value)
    }
}

public extension LockedAtomic where Value: Equatable {
    
    func compareExchange(expected: Value, desired: Value) -> (exchanged: Bool, original: Value) {
        self.lock.lock()
        defer { self.lock.unlock() }
        let original = value
        guard original == expected else {
            return (false, original)
        }
        value = desired
        return (true, original)
    }
}

public extension LockedAtomic where Value: Numeric {
    
    func loadThenWrappingIncrement(by operand: Value = 1) -> Value {
        self.lock.lock()
        defer { self.lock.unlock() }
        let original = value
        value += operand
        return original
    }
    
    func loadThenWrappingDecrement(by operand: Value = 1) -> Value {
        self.lock.lock()
        defer { self.lock.unlock() }
        let original = value
        value -= operand
        return original
    }
}
