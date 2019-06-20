struct PeekableIterator<Element>: IteratorProtocol {
    
    private var iterator: AnyIterator<Element>
    private var buffer: CircularBuffer<Element>
    
    var consumedCount: Int
    
    init<I: IteratorProtocol>(_ iterator: I) where I.Element == Element {
        self.iterator = AnyIterator(iterator)
        self.buffer = CircularBuffer()
        self.consumedCount = 0
    }
    
    mutating func peek() -> Element? {
        if let value = self.iterator.next() {
            self.buffer.append(value)
            return value
        }
        return nil
    }

    mutating func next() -> Element? {
        let value = self.buffer.popFirst() ?? self.iterator.next()
        
        if value != nil {
            self.consumedCount += 1
        }
        
        return value
    }
}
