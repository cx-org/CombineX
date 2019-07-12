import Foundation

final class Lock {
    
    private let locking: NSLocking
    
    #if DEBUG
    private var q = DispatchQueue(label: UUID().uuidString)
    private var h: [String] = []
    
    var history: [String] {
        return self.q.sync { self.h }
    }
    #endif
    
    init(recursive: Bool = false) {
        self.locking = recursive ? NSRecursiveLock() : NSLock()
    }
    
    func lock(file: StaticString = #file, line: UInt = #line) {
        #if DEBUG
        self.q.async {
            self.h.append("LOCK: \(file)#\(line)")
        }
        #endif
        self.locking.lock()
    }
    
    func unlock(file: StaticString = #file, line: UInt = #line) {
        #if DEBUG
        self.q.async {
            self.h.append("UNLOCK: \(file)#\(line)")
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
