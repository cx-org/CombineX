import Foundation

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
        Logger._output(.trace, items, separator: separator, terminator: terminator, object: self)
    }

    func debug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        Logger._output(.debug, items, separator: separator, terminator: terminator, object: self)
    }
    
    func info(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        Logger._output(.info, items, separator: separator, terminator: terminator, object: self)
    }
    
    func notice(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        Logger._output(.notice, items, separator: separator, terminator: terminator, object: self)
    }
    
    func warning(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        Logger._output(.warning, items, separator: separator, terminator: terminator, object: self)
    }
    
    func error(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        Logger._output(.error, items, separator: separator, terminator: terminator, object: self)
    }
    
    func critical(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        Logger._output(.critical, items, separator: separator, terminator: terminator, object: self)
    }

}

class Logger {
    
    static let shared = Logger()

    enum Level: Int {
        case trace, debug, info, notice, warning, error, critical
    }
    
    static func output(_ level: Level, _ items: Any..., separator: String = " ", terminator: String = "\n", object: Logging? = nil) {
        self._output(level, items, separator: separator, terminator: terminator, object: object)
    }
    
    static func _output(_ level: Level, _ items: [Any], separator: String = " ", terminator: String = "\n", object: Logging? = nil) {
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
        print(symbol, id, str, terminator: terminator)
    }
}

// MARK: Enable
extension Logger {
    
    private static let enabledList = Atom<[ObjectIdentifier]>(val: [])
    
    static func enableLogging(_ object: AnyObject) {
        self.enabledList.withLockMutating {
            $0.append(ObjectIdentifier(object))
        }
    }
}
