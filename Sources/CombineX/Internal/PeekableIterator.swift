struct PeekableIterator<Element>: IteratorProtocol {
    
    var iterator: AnyIterator<Element>
    var buffer: CircularBuffer<Element>
    
    init<I: IteratorProtocol>(_ iterator: I) where I.Element == Element {
        self.iterator = AnyIterator(iterator)
        self.buffer = CircularBuffer()
    }
    
    mutating func peek() -> Element? {
        if let value = self.iterator.next() {
            self.buffer.append(value)
            return value
        }
        return nil
    }

    mutating func next() -> Element? {
        if let value = self.buffer.popFirst() {
            return value
        }
        return self.iterator.next()
    }
}
