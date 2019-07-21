enum CustomError: Int, Error {
    case e0
    case e1
    case e2
}

extension CustomError: Equatable {
    
    static func == (lhs: CustomError, rhs: CustomError) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
