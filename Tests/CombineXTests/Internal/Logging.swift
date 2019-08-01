/*
 Simple log util, use only for test!
 */

protocol Logging: AnyObject {
    
    var name: String? {
        get
    }
}

extension Logging {
    
    var name: String? {
        return nil
    }
}

extension Logging {
    
    func trace(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        logger._output(.trace, items, separator: separator, terminator: terminator, object: self)
    }

    func debug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        logger._output(.debug, items, separator: separator, terminator: terminator, object: self)
    }
    
    func info(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        logger._output(.info, items, separator: separator, terminator: terminator, object: self)
    }
    
    func notice(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        logger._output(.notice, items, separator: separator, terminator: terminator, object: self)
    }
    
    func warning(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        logger._output(.warning, items, separator: separator, terminator: terminator, object: self)
    }
    
    func error(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        logger._output(.error, items, separator: separator, terminator: terminator, object: self)
    }
    
    func critical(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        logger._output(.critical, items, separator: separator, terminator: terminator, object: self)
    }

}

let logger = Logger.shared

class Logger {
    
    static let shared = Logger()
    
    private let enabledList = Atom<Set<ObjectIdentifier>>(val: [])
    
    private init() {
    }

    enum Level: Int {
        case trace, debug, info, notice, warning, error, critical
    }
    
    func output(_ level: Level, _ items: Any..., separator: String = " ", terminator: String = "\n", object: Logging? = nil) {
        self._output(level, items, separator: separator, terminator: terminator, object: object)
    }
    
    fileprivate func _output(_ level: Level, _ items: [Any], separator: String = " ", terminator: String = "\n", object: Logging? = nil) {
        if let object = object {
            guard self.enabledList.get().contains(ObjectIdentifier(object)) else {
                return
            }
        }
        
        let levels = "💜💙💚💛🧡♥️🖤".map { "\($0)" }
        let symbol = levels[level.rawValue]

        var id = ""
        if let object = object {
            id = "\(type(of: object))"
            if let name = object.name {
                id += "-\(name)"
            }
        }
        
        let str = items.map { "\($0)" }.joined(separator: separator)
        print(symbol, "[\(id)]:", str, terminator: terminator)
    }
    
    func enableLogging(_ object: AnyObject) {
        self.enabledList.withLockMutating {
            let id = ObjectIdentifier(object)
            $0.insert(id)
        }
    }
    
    func disableLogging(_ object: AnyObject) {
        self.enabledList.withLockMutating {
            let id = ObjectIdentifier(object)
            $0.remove(id)
        }
    }
    
    func reset() {
        _ = self.enabledList.exchange(with: [])
    }
}
