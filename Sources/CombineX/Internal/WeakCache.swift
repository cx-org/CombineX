import CXUtility

class WeakCache<Key: AnyObject, Value: AnyObject> {
    
    private var storage: [WeakBox<Key>: WeakBox<Value>] = [:]
    
    private func reap() {
        // FIXME: Lock
        storage = storage.filter { key, value in
            return key.value != nil && value.value != nil
        }
    }
    
    public subscript(key: Key) -> Value? {
        get {
            return storage[WeakBox(key)]?.value
        }
        set {
            reap()
            guard let value = newValue else {
                storage[WeakBox(key)] = nil
                return
            }
            storage[WeakBox(key)] = WeakBox(value)
        }
    }
}
