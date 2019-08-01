enum TestError: Int, Error, CustomStringConvertible, Codable {
    case e0
    case e1
    case e2
    
    var description: String {
        switch self {
        case .e0:       return "TestError.e0"
        case .e1:       return "TestError.e1"
        case .e2:       return "TestError.e2"
        }
    }
}

extension TestError: Equatable {
    
    static func == (lhs: TestError, rhs: TestError) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
