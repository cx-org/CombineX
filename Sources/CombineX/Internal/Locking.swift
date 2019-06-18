import Foundation

final class Lock: NSLocking {
    
    private let locking: NSLocking
    private lazy var lazyQueue = DispatchQueue(label: UUID().uuidString)
    
    init(recursive: Bool = false) {
        if recursive {
            self.locking = NSRecursiveLock()
        } else {
            self.locking = NSLock()
        }
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
    
    func withLockLazy(_ body: @escaping () -> Void) {
        self.lazyQueue.async {
            self.lock()
            body()
            self.unlock()
        }
    }
}
