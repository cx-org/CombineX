import Foundation

#if CombineQ
import CombineQ
#else
import Combine
#endif

private class IdGen {
    static var current = 0
    static let lock = NSLock()
    
    static func next() -> Int {
        lock.lock()
        defer {
            current += 1
            lock.unlock()
        }
        
        return current
    }
}

class AnotherSubscription: Subscription {
    
    let id = IdGen.next()
    
    func request(_ demand: Subscribers.Demand) {
        print("[AnotherSubscription: \(id)]", "request demand", demand)
    }
    
    func cancel() {
        print("[AnotherSubscription: \(id)]", "cancel")
    }
    
    deinit {
        print("[AnotherSubscription: \(id)]", "deinit")
    }
}
