import Foundation

private var object_observer_key = 0

class ObjectObserver {
    
    weak var object: AnyObject?
    
    let desc: String
    init(desc: String) {
        self.desc = desc
    }
    
    static func observe(_ object: AnyObject) {
        let observer = ObjectObserver(desc: "\(object)")
        objc_setAssociatedObject(object, &object_observer_key, observer, .OBJC_ASSOCIATION_RETAIN)
    }
    
    deinit {
        print("[ObjectObserver] \(desc) deinit")
    }
}
