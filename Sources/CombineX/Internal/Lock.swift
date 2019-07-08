import Foundation

final class Lock {
    
    private let locking: NSLocking
    
    #if DEBUG
    private var q = DispatchQueue(label: UUID().uuidString)
    private var _history: [String] = []
    var history: [String] {
        return q.sync {
            self._history
        }
    }
    #endif
    
    init(recursive: Bool = false) {
        if recursive {
            self.locking = NSRecursiveLock()
        } else {
            self.locking = NSLock()
        }
    }
    
    func lock(file: StaticString = #file, line: UInt = #line) {
        self.locking.lock()
        #if DEBUG
        self.q.async {
            self._history.append("LOCK: \(file)#\(line)")
        }
        #endif
    }
    
    func unlock(file: StaticString = #file, line: UInt = #line) {
        self.locking.unlock()
        #if DEBUG
        self.q.async {
            self._history.append("UNLOCK: \(file)#\(line)")
        }
        #endif
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
