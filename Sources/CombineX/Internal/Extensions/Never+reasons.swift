enum APIViolation {}

extension APIViolation {
    
    static func valueBeforeSubscription(file: StaticString = #file, line: UInt = #line) -> Never {
        fatalError("API Violation: received an unexpected value before receiving a Subscription", file: file, line: line)
    }
    
    static func unexpectedCompletion(file: StaticString = #file, line: UInt = #line) -> Never {
        fatalError("API Violation: received an unexpected completion", file: file, line: line)
    }
}

extension Never {
    
    static func requiresImplementation(_ fn: String = #function, file: StaticString = #file, line: UInt = #line) -> Never {
        fatalError("\(fn) is not yet implemented", file: file, line: line)
    }
    
    static func requiresConcreteImplementation(_ fn: String = #function, file: StaticString = #file, line: UInt = #line) -> Never {
        fatalError("\(fn) must be overriden in subclass", file: file, line: line)
    }
    
    static func unsupported(_ fn: String = #function, file: StaticString = #file, line: UInt = #line) -> Never {
        fatalError("\(fn) is not supported on this platform", file: file, line: line)
    }
    
    static func never(_ fn: String = #function, file: StaticString = #file, line: UInt = #line) -> Never {
        fatalError("Never", file: file, line: line)
    }
}
