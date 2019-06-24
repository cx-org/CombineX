// MARK: - Array
extension Array {
    
    mutating func tryRemoveFirst() -> Element? {
        if self.isEmpty {
            return nil
        }
        return self.removeFirst()
    }
}
