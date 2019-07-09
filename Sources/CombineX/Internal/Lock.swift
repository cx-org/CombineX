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
        #if DEBUG
        self.q.async {
            self._history.append("LOCK: \(file)#\(line)")
        }
        #endif
        self.locking.lock()
    }
    
    func unlock(file: StaticString = #file, line: UInt = #line) {
        #if DEBUG
        self.q.async {
            self._history.append("UNLOCK: \(file)#\(line)")
        }
        #endif
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
