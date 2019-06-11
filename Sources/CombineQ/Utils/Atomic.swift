import Foundation

class Atomic<Value> {
    
    private let lock = NSLock()
    private var value: Value
    
    init(_ value: Value) {
        self.value = value
    }
    
    func load() -> Value {
        lock.lock(); defer { lock.unlock() }
        return self.value
    }
    
    func store(_ value: Value) {
        lock.lock(); defer { lock.unlock() }
        self.value = value
    }
    
    /// Stores a value.
    ///
    /// - Returns: The old value.
    func exchange(with value: Value) -> Value {
        lock.lock(); defer { lock.unlock() }
        let old = self.value
        self.value = value
        return old
    }
    
    func read<Result>(_ body: @escaping (Value) throws -> Result) rethrows -> Result {
        lock.lock(); defer { lock.unlock() }
        return try body(self.value)
    }
    
    func write<Result>(_ body: @escaping (inout Value) throws -> Result) rethrows -> Result {
        lock.lock(); defer { lock.unlock() }
        return try body(&self.value)
    }
}

extension Atomic where Value: Equatable {
    
    /// Stores a value at the specified index of the array, if it equals a value.
    ///
    /// - Returns: The old value.
    func compareAndExchange(expected: Value, desired: Value) -> Bool {
        lock.lock(); defer { lock.unlock() }
        if self.value == expected {
            self.value = desired
            return true
        }
        return false
    }
}

extension Atomic where Value: AdditiveArithmetic {
    
    /// Adds the provided value to the existing value.
    ///
    /// - Returns: The old value.
    func add(_ rhs: Value) -> Value {
        self.write {
            let old = $0
            $0 += rhs
            return old
        }
    }
    
    /// Subtracts the provided value from the existing value.
    ///
    /// Subtracts `rhs` from this value.
    func sub(_ rhs: Value) -> Value {
        self.write {
            let old = $0
            $0 -= rhs
            return old
        }
    }
}

extension Atomic where Value: BinaryInteger {
    
    func and(_ rhs: Value) -> Value {
        self.write {
            let old = $0
            $0 &= rhs
            return old
        }
    }
    
    func or(_ rhs: Value) -> Value {
        self.write {
            let old = $0
            $0 |= rhs
            return old
        }
    }
    
    func xor(_ rhs: Value) -> Value {
        self.write {
            let old = $0
            $0 ^= rhs
            return old
        }
    }
}
