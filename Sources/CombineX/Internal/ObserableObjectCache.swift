import CXUtility

// Ad-hoc cache for ObservableObject that works on following assumption:
//
// - Once the value is added, it will not be (manually) removed or modified.

class TypeInfoCache<Key: Hashable, Value> {
    
    private var storage: [Key: Value] = [:]
    
    private var lock = Lock()
    
    func value(for key: Key) -> Value? {
        return storage[key]
    }
    
    func value(for key: Key, make: () throws -> Value) rethrows -> Value {
        if let value = storage[key] {
            return value
        }
        lock.lock()
        defer { lock.unlock() }
        if let value = storage[key] {
            // avoid double write
            return value
        }
        let value = try make()
        storage[key] = value
        return value
    }
}

class ObservableObjectPublisherCache<Key: AnyObject, Value: AnyObject> {
    
    private var storage: [WeakHashBox<Key>: WeakHashBox<Value>] = [:]
    
    private var lock = Lock()
    
    private func cleanup() {
        storage = storage.filter { key, value in
            return key.value != nil && value.value != nil
        }
    }
    
    func value(for key: Key) -> Value? {
        let wkey = WeakHashBox(key)
        guard let valueBox = storage[wkey] else {
            return nil
        }
        if let boxedValue = valueBox.value {
            return boxedValue
        } else {
            lock.lock()
            storage.removeValue(forKey: wkey)
            lock.unlock()
            return nil
        }
    }
    
    func value(for key: Key, make: () throws -> Value) rethrows -> Value {
        let wkey = WeakHashBox(key)
        if let value = storage[wkey]?.value {
            return value
        }
        lock.lock()
        defer { lock.unlock() }
        if let value = storage[wkey]?.value {
            // avoid double write
            return value
        }
        let value = try make()
        if (storage.count + 1) >= storage.capacity {
            cleanup()
        }
        storage[wkey] = WeakHashBox(value)
        return value
    }
}
