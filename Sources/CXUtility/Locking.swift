import CXLibc

public protocol Locking {
    
    func lock()
    
    func tryLock() -> Bool
    
    func unlock()
}

extension Locking {
    
    public func withLock<T>(_ body: () throws -> T) rethrows -> T {
        self.lock(); defer { self.unlock() }
        return try body()
    }
    
    public func withLockGet<T>(_ body: @autoclosure () throws -> T) rethrows -> T {
        self.lock(); defer { self.unlock() }
        return try body()
    }
}

// MARK: - Lock

public struct Lock: Locking {
    
    private let _lock: UnsafeMutableRawPointer
    
    public init() {
        #if canImport(Darwin)
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            _lock = OSUnfairLock().raw
            return
        }
        #endif
        _lock = PThreadMutex(recursive: false).raw
    }
    
    public func cleanupLock() {
        #if canImport(Darwin)
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            _lock.as(OSUnfairLock.self).cleanupLock()
            return
        }
        #endif
        _lock.as(PThreadMutex.self).cleanupLock()
    }
    
    public func lock() {
        #if canImport(Darwin)
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            _lock.as(OSUnfairLock.self).lock()
            return
        }
        #endif
        _lock.as(PThreadMutex.self).lock()
    }
    
    public func tryLock() -> Bool {
        #if canImport(Darwin)
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            return _lock.as(OSUnfairLock.self).tryLock()
        }
        #endif
        return _lock.as(PThreadMutex.self).tryLock()
    }
    
    public func unlock() {
        #if canImport(Darwin)
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            _lock.as(OSUnfairLock.self).unlock()
            return
        }
        #endif
        _lock.as(PThreadMutex.self).unlock()
    }
}

// MARK: - RecursiveLock

public struct RecursiveLock: Locking {
    
    private let _lock: UnsafeMutableRawPointer
    
    public init() {
        #if canImport(DarwinPrivate)
        if #available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *) {
            _lock = OSUnfairRecursiveLock().raw
            return
        }
        #endif
        _lock = PThreadMutex(recursive: true).raw
    }
    
    public func cleanupLock() {
        #if canImport(DarwinPrivate)
        if #available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *) {
            _lock.as(OSUnfairRecursiveLock.self).cleanupLock()
            return
        }
        #endif
        _lock.as(PThreadMutex.self).cleanupLock()
    }
    
    public func lock() {
        #if canImport(DarwinPrivate)
        if #available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *) {
            _lock.as(OSUnfairRecursiveLock.self).lock()
            return
        }
        #endif
        _lock.as(PThreadMutex.self).lock()
    }
    
    public func tryLock() -> Bool {
        #if canImport(DarwinPrivate)
        if #available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *) {
            return _lock.as(OSUnfairRecursiveLock.self).tryLock()
        }
        #endif
        return _lock.as(PThreadMutex.self).tryLock()
    }
    
    public func unlock() {
        #if canImport(DarwinPrivate)
        if #available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *) {
            _lock.as(OSUnfairRecursiveLock.self).unlock()
            return
        }
        #endif
        _lock.as(PThreadMutex.self).unlock()
    }
}

#if canImport(Darwin)

// MARK: - OSUnfairLock

private typealias OSUnfairLock = UnsafeMutablePointer<os_unfair_lock_s>

@available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
private extension UnsafeMutablePointer where Pointee == os_unfair_lock_s {
    
    init() {
        let l = UnsafeMutablePointer.allocate(capacity: 1)
        l.initialize(to: os_unfair_lock_s())
        self = l
    }
    
    func cleanupLock() {
        deinitialize(count: 1)
        deallocate()
    }
    
    func lock() {
        os_unfair_lock_lock(self)
    }
    
    func tryLock() -> Bool {
        return os_unfair_lock_trylock(self)
    }
    
    func unlock() {
        os_unfair_lock_unlock(self)
    }
}

// MARK: - OSUnfairRecursiveLock

// TODO: Use os_unfair_recursive_lock_s
#if canImport(DarwinPrivate)

private typealias OSUnfairRecursiveLock = UnsafeMutablePointer<os_unfair_recursive_lock_s>

@available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
private extension UnsafeMutablePointer where Pointee == os_unfair_recursive_lock_s {
    
    init() {
        let l = UnsafeMutablePointer.allocate(capacity: 1)
        l.initialize(to: os_unfair_recursive_lock_s())
        self = l
    }
    
    func cleanupLock() {
        deinitialize(count: 1)
        deallocate()
    }
    
    func lock() {
        os_unfair_recursive_lock_lock(self)
    }
    
    func tryLock() -> Bool {
        let result = os_unfair_recursive_lock_trylock(self)
        return result
    }
    
    func unlock() {
        os_unfair_recursive_lock_unlock(self)
    }
}

#endif // canImport(DarwinPrivate)

#endif // canImport(Darwin)

// MARK: - PThreadMutex

private typealias PThreadMutex = UnsafeMutablePointer<pthread_mutex_t>

private extension UnsafeMutablePointer where Pointee == pthread_mutex_t {
    
    init(recursive: Bool) {
        let l = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)
        if recursive {
            var attr = pthread_mutexattr_t()
            pthread_mutexattr_init(&attr)
            pthread_mutexattr_settype(&attr, Int32(PTHREAD_MUTEX_RECURSIVE)).assertZero()
            pthread_mutex_init(l, &attr).assertZero()
        } else {
            pthread_mutex_init(l, nil).assertZero()
        }
        self = l
    }
    
    func cleanupLock() {
        pthread_mutex_destroy(self).assertZero()
        deinitialize(count: 1)
        deallocate()
    }
    
    func lock() {
        pthread_mutex_lock(self).assertZero()
    }
    
    func tryLock() -> Bool {
        return pthread_mutex_trylock(self) == 0
    }
    
    func unlock() {
        pthread_mutex_unlock(self).assertZero()
    }
}

// MARK: Helpers

private extension UnsafeMutablePointer {
    
    @inline(__always)
    var raw: UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer(self)
    }
}

private extension UnsafeMutableRawPointer {
    
    @inline(__always)
    func `as`<T>(_ type: UnsafeMutablePointer<T>.Type) -> UnsafeMutablePointer<T> {
        return assumingMemoryBound(to: T.self)
    }
}

private extension Int32{
    
    @inline(__always)
    func assertZero() {
        // assert or precondition?
        assert(self == 0)
    }
}
