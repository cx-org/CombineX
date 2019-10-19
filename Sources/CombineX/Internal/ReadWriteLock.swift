#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

final class ReadWriteLock {
    
    var lock = pthread_rwlock_t()
    
    init() {
        precondition(pthread_rwlock_init(&lock, nil) == 0)
    }
    
    deinit {
        precondition(pthread_rwlock_destroy(&lock) == 0)
    }
    
    func lockRead() {
        precondition(pthread_rwlock_rdlock(&lock) == 0)
    }
    
    func unlockRead() {
        precondition(pthread_rwlock_unlock(&lock) == 0)
    }
    
    func lockWrite() {
        precondition(pthread_rwlock_wrlock(&lock) == 0)
    }
    
    func unlockWrite() {
        precondition(pthread_rwlock_unlock(&lock) == 0)
    }
}
