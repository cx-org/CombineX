extension Double {
    
    var clampedToInt: Int {
        switch self {
        case ...Double(Int.min):
            return Int.min
        case Double(Int.max)...:
            return Int.max
        default:
            return Int(self)
        }
    }
}
