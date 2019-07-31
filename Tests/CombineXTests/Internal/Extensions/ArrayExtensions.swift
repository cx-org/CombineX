// MARK: - test
extension Array {
    
    static func make(count: Int, make: @autoclosure () -> Element) -> [Element] {
        var elements: [Element] = []
        count.times {
            elements.append(make())
        }
        return elements
    }
}

extension Array where Element: Equatable {
    
    func count(of e: Element) -> Int {
        return self.filter { $0 == e }.count
    }
}
