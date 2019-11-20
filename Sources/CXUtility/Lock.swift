import Foundation

@usableFromInline
protocol NSTryLocking: NSLocking {
    func `try`() -> Bool
}

extension NSRecursiveLock: NSTryLocking {}
extension NSLock: NSTryLocking {}

public final class Lock {

    @usableFromInline
    let locking: NSTryLocking
    
    @inlinable
    public init(recursive: Bool = false) {
        self.locking = recursive ? NSRecursiveLock(): NSLock()
    }
    
    @inlinable
    public func lock(file: StaticString = #file, line: UInt = #line) {
        self.locking.lock()
    }
    
    @inlinable
    public func `try`() -> Bool {
        return self.locking.try()
    }
    
    @inlinable
    public func unlock(file: StaticString = #file, line: UInt = #line) {
        self.locking.unlock()
    }
    
    @inlinable
    public func withLock<T>(_ body: () throws -> T) rethrows -> T {
        self.lock(); defer { self.unlock() }
        return try body()
    }
    
    @inlinable
    public func withLockGet<T>(_ body: @autoclosure () throws -> T) rethrows -> T {
        self.lock(); defer { self.unlock() }
        return try body()
    }
}
