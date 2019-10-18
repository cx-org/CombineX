import CXUtility

class WeakCache<Key: AnyObject, Value: AnyObject> {
    
    private var storage: [WeakHashBox<Key>: WeakHashBox<Value>] = [:]
    
    private func reap() {
        // FIXME: Lock
        storage = storage.filter { key, value in
            return key.value != nil && value.value != nil
        }
    }
    
    public subscript(key: Key) -> Value? {
        get {
            return storage[WeakHashBox(key)]?.value
        }
        set {
            reap()
            guard let value = newValue else {
                storage[WeakHashBox(key)] = nil
                return
            }
            storage[WeakHashBox(key)] = WeakHashBox(value)
        }
    }
}
