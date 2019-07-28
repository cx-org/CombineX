enum Global {
}

extension Global {
    
    @usableFromInline
    static func RequiresImplementation(_ fn: String = #function, file: StaticString = #file, line: UInt = #line) -> Never {
        fatalError("\(fn) is not yet implemented", file: file, line: line)
    }
    
    @usableFromInline
    static func RequiresConcreteImplementation(_ fn: String = #function, file: StaticString = #file, line: UInt = #line) -> Never {
        fatalError("\(fn) must be overriden in subclass", file: file, line: line)
    }
    
    @usableFromInline
    static func Unsupported(_ fn: String = #function, file: StaticString = #file, line: UInt = #line) -> Never {
        fatalError("\(fn) is not supported on this platform", file: file, line: line)
    }
    
    @usableFromInline
    static func Impossible(_ fn: String = #function, file: StaticString = #file, line: UInt = #line) -> Never {
        fatalError("Impossible", file: file, line: line)
    }
}
