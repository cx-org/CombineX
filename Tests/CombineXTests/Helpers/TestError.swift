enum TestError: Int, Error, CustomStringConvertible {
    case e0
    case e1
    case e2
    
    var description: String {
        switch self {
        case .e0:       return ".e0"
        case .e1:       return ".e1"
        case .e2:       return ".e2"
        }
    }
}

extension TestError: Equatable {
    
    static func == (lhs: TestError, rhs: TestError) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
