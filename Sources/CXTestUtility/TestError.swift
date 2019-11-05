public enum TestError: Int, Error, Equatable, CustomStringConvertible, Codable {
    case e0
    case e1
    case e2
    
    public var description: String {
        switch self {
        case .e0:       return "TestError.e0"
        case .e1:       return "TestError.e1"
        case .e2:       return "TestError.e2"
        }
    }
}
