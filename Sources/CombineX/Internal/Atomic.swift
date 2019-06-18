import Foundation

final class Atomic<Value> {
    
    private let lock: Lock
    private var value: Value
    
    init(value: Value) {
        self.value = value
        self.lock = Lock()
    }
    
    func load() -> Value {
        lock.lock(); defer { lock.unlock() }
        return self.value
    }
    
    func store(_ value: Value) {
        lock.lock(); defer { lock.unlock() }
        self.value = value
    }
    
    /// Stores the provided value.
    ///
    /// - Returns: The old value.
    func exchange(with value: Value) -> Value {
        lock.lock(); defer { lock.unlock() }
        let old = self.value
        self.value = value
        return old
    }
    
    func withLock<Result>(_ body: (Value) throws -> Result) rethrows -> Result {
        lock.lock(); defer { lock.unlock() }
        return try body(self.value)
    }
    
    func withLockMutating<Result>(_ body: (inout Value) throws -> Result) rethrows -> Result {
        lock.lock(); defer { lock.unlock() }
        return try body(&self.value)
    }
    
    func withLockVoid(_ body: () throws -> Void) rethrows {
        lock.lock(); defer { lock.unlock() }
        try body()
    }
}

extension Atomic where Value: Equatable {
    
    /// Stores the `newVaue` if it equals the `expected`.
    ///
    /// - Returns: `true` if the store occurred.
    func compareAndStore(expected: Value, newVaue: Value) -> Bool {
        return self.withLockMutating {
            if $0 == expected {
                $0 = newVaue
                return true
            }
            return false
        }
    }
}

extension Atomic where Value: AdditiveArithmetic {
    
    /// Adds the provided value to the existing value.
    ///
    /// - Returns: The old value.
    func add(_ value: Value) -> Value {
        return self.withLockMutating {
            let old = $0
            $0 += value
            return old
        }
    }
    
    /// Subtracts the provided value from the existing value.
    ///
    /// - Returns: The old value.
    func sub(_ value: Value) -> Value {
        return self.withLockMutating {
            let old = $0
            $0 -= value
            return old
        }
    }
}

extension Atomic where Value: BinaryInteger {
    
    /// Computes a bitwise AND on the existing value with the provided value.
    ///
    /// - Returns: The old value.
    func and(_ value: Value) -> Value {
        return self.withLockMutating {
            let old = $0
            $0 &= value
            return old
        }
    }
    
    /// Computes a bitwise OR on the existing value with the provided value.
    ///
    /// - Returns: The old value.
    func or(_ value: Value) -> Value {
        return self.withLockMutating {
            let old = $0
            $0 |= value
            return old
        }
    }
    
    /// Computes a bitwise XOR on the existing value with the provided value.
    ///
    /// - Returns: The old value.
    func xor(_ value: Value) -> Value {
        return self.withLockMutating {
            let old = $0
            $0 ^= value
            return old
        }
    }
}

extension Atomic {
    
    class func ifNil(_ atomic: Atomic<Value?>, store value: Value) -> Bool {
        atomic.lock.lock(); defer { atomic.lock.unlock() }
        
        if atomic.value == nil {
            atomic.value = value
            return true
        }
        
        return false
    }
}

