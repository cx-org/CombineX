protocol Logging {
    
    var isLogEnabled: Bool { get set }
    
    func log(_ items: Any...)
}

extension Logging {
    
    func log(_ items: Any...) {
        guard self.isLogEnabled else {
            return
        }
        
        let str = items.map { "\($0)" }.joined(separator: " ")
        print(str)
    }
}
