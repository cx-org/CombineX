@usableFromInline
enum Global {
}

extension Global {
    
    @inlinable
    static func RequiresImplementation(_ fn: String = #function, file: StaticString = #file, line: UInt = #line) -> Never {
        fatalError("\(fn) is not yet implemented", file: file, line: line)
    }
    
    @inlinable
    static func RequiresConcreteImplementation(_ fn: String = #function, file: StaticString = #file, line: UInt = #line) -> Never {
        fatalError("\(fn) must be overriden in subclass", file: file, line: line)
    }
    
    @inlinable
    static func Unsupported(_ fn: String = #function, file: StaticString = #file, line: UInt = #line) -> Never {
        fatalError("\(fn) is not supported on this platform", file: file, line: line)
    }
    
    @inlinable
    static func Never(_ fn: String = #function, file: StaticString = #file, line: UInt = #line) -> Never {
        fatalError("Never", file: file, line: line)
    }
}
