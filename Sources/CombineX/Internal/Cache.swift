import CXUtility

class Cache<Key: Hashable, Value> {
    
    private var storage: [Key: Value] = [:]
    
    private var lock = ReadWriteLock()
    
    subscript(key: Key) -> Value? {
        get {
            lock.lockRead()
            defer { lock.unlockRead() }
            return storage[key]
        }
        set {
            lock.lockWrite()
            defer { lock.unlockWrite() }
            guard let value = newValue else {
                storage.removeValue(forKey: key)
                return
            }
            storage[key] = value
        }
    }
}

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
            let wkey = WeakHashBox(key)
            guard let valueBox = storage[wkey] else {
                return nil
            }
            if let boxedValue = valueBox.value {
                return boxedValue
            } else {
                storage.removeValue(forKey: wkey)
                return nil
            }
        }
        set {
            lock.lockWrite()
            defer { lock.unlockWrite() }
            let wkey = WeakHashBox(key)
            guard let value = newValue else {
                storage.removeValue(forKey: wkey)
                return
            }
            if storage[wkey] == nil, (storage.count + 1) >= storage.capacity {
                faseReap()
            }
            storage[wkey] = WeakHashBox(value)
        }
    }
    
    func reap() {
        lock.lockWrite()
        defer { lock.unlockWrite() }
        faseReap()
    }
}
