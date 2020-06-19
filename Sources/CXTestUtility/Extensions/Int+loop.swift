extension Int {
    
    public func times(_ body: (Int) -> Void) {
        guard self > 0 else {
            return
        }
        for i in 0..<self {
            body(i)
        }
    }
    
    public func times(_ body: () -> Void) {
        self.times { _ in
            body()
        }
    }
}
