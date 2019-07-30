import Foundation

@usableFromInline
final class Lock {

    @usableFromInline
    let locking: NSLocking
    
    @inlinable
    init(recursive: Bool = false) {
        self.locking = recursive ? NSRecursiveLock() : NSLock()
    }
    
    @inlinable
    func lock(file: StaticString = #file, line: UInt = #line) {
        self.locking.lock()
    }
    
    @inlinable
    func unlock(file: StaticString = #file, line: UInt = #line) {
        self.locking.unlock()
    }
    
    @inlinable
    func withLock<T>(_ body: () throws -> T) rethrows -> T {
        self.lock(); defer { self.unlock() }
        return try body()
    }
    
    @inlinable
    func withLockGet<T>(_ body: @autoclosure () throws -> T) rethrows -> T {
        self.lock(); defer { self.unlock() }
        return try body()
    }
}
