import Foundation

class Atomic<Value> {

    private let lock = NSLock()
    private var value: Value
    
    init(_ value: Value) {
        self.value = value
    }
    
    func read<T>(_ body: (Value) throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try body(self.value)
    }
    
    func write<T>(_ body: (inout Value) throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try body(&self.value)
    }
}
