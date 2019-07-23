enum TestError: Int, Error {
    case e0
    case e1
    case e2
}

extension TestError: Equatable {
    
    static func == (lhs: TestError, rhs: TestError) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
