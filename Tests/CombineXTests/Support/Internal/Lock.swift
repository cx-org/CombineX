import Foundation

final class Lock {
    
    private let locking: NSLocking
    
    init(recursive: Bool = false) {
        self.locking = recursive ? NSRecursiveLock() : NSLock()
    }
    
    func lock() {
        self.locking.lock()
    }
    
    func unlock() {
        self.locking.unlock()
    }
    
    func withLock<T>(_ body: () throws -> T) rethrows -> T {
        self.lock(); defer { self.unlock() }
        return try body()
    }
    
    func withLockGet<T>(_ body: @autoclosure () throws -> T) rethrows -> T {
        self.lock(); defer { self.unlock() }
        return try body()
    }
}
