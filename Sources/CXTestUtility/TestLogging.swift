/*
 Simple log util, for testing only!
 */

import CXUtility

public protocol TestLogging: AnyObject {
    
    var name: String? {
        get
    }
}

public extension TestLogging {
    
    var name: String? {
        return nil
    }
}

public extension TestLogging {
    
    func trace(_ items: Any...) {
        logger._output(.trace, items, object: self)
    }

    func debug(_ items: Any...) {
        logger._output(.debug, items, object: self)
    }
    
    func info(_ items: Any...) {
        logger._output(.info, items, object: self)
    }
    
    func notice(_ items: Any...) {
        logger._output(.notice, items, object: self)
    }
    
    func warning(_ items: Any...) {
        logger._output(.warning, items, object: self)
    }
    
    func error(_ items: Any...) {
        logger._output(.error, items, object: self)
    }
    
    func critical(_ items: Any...) {
        logger._output(.critical, items, object: self)
    }
}

public let logger = Logger.shared

public class Logger {
    
    public static let shared = Logger()
    
    private let enabledList = Atom<Set<ObjectIdentifier>>(val: [])
    
    private init() {
    }

    public enum Level: Int {
        case trace, debug, info, notice, warning, error, critical
    }
    
    public func output(_ level: Level, _ items: Any..., object: TestLogging? = nil) {
        self._output(level, items, object: object)
    }
    
    fileprivate func _output(_ level: Level, _ items: [Any], object: TestLogging? = nil) {
        if let object = object {
            guard self.enabledList.get().contains(ObjectIdentifier(object)) else {
                return
            }
        }
        
        let levels = "💜💙💚💛🧡♥️🖤".map { "\($0)" }
        let symbol = levels[level.rawValue]

        var prefix = ""
        if let object = object {
            prefix = "\(type(of: object))"
            if let name = object.name {
                prefix += "-\(name)"
            }
        }
        
        let str = items.map { "\($0)" }.joined()
        print(symbol, "[\(prefix)]:", str)
    }
    
    public func enable(_ object: TestLogging) {
        self.enabledList.withLockMutating {
            let id = ObjectIdentifier(object)
            $0.insert(id)
        }
    }
    
    public func disable(_ object: TestLogging) {
        self.enabledList.withLockMutating {
            let id = ObjectIdentifier(object)
            $0.remove(id)
        }
    }
    
    public func reset() {
        _ = self.enabledList.exchange(with: [])
    }
}
