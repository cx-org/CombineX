import CXUtility

class WeakCache<Key: AnyObject, Value: AnyObject> {
    
    private var storage: [WeakHashBox<Key>: WeakHashBox<Value>] = [:]
    
    private var lock = ReadWriteLock()
    
    private func faseReap() {
        storage = storage.filter { key, value in
            return key.value != nil && value.value != nil
        }
    }
    
    subscript(key: Key) -> Value? {
        get {
            lock.lockRead()
            defer { lock.unlockRead() }
            return storage[WeakHashBox(key)]?.value
        }
        set {
            lock.lockWrite()
            defer { lock.unlockWrite() }
            guard let value = newValue else {
                storage.removeValue(forKey: WeakHashBox(key))
                return
            }
            if (storage.count + 1) >= storage.capacity {
                faseReap()
            }
            storage[WeakHashBox(key)] = WeakHashBox(value)
        }
    }
    
    func reap() {
        lock.lockWrite()
        defer { lock.unlockWrite() }
        faseReap()
    }
}
