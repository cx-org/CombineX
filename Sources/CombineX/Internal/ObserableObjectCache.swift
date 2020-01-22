#if !COCOAPODS
import CXUtility
#endif

// Ad-hoc cache for ObservableObject that works on following assumption:
//
// - Once the value is added, it will not be (manually) removed or modified.
class ObservableObjectPublisherCache<Key: AnyObject, Value: AnyObject> {
    
    private var storage: [WeakHashBox<Key>: WeakHashBox<Value>] = [:]
    
    private var lock = Lock()
    
    private func cleanup() {
        storage = storage.filter { key, value in
            return key.value != nil && value.value != nil
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
        if storage.count == storage.capacity {
            // will allocate new storage
            cleanup()
        }
        storage[wkey] = WeakHashBox(value)
        return value
    }
}
