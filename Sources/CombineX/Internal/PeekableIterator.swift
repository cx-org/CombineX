struct PeekableIterator<Element>: IteratorProtocol {
    
    private var iterator: AnyIterator<Element>
    
    // TODO: Use a circular buffer.
    private var buffer: [Element]
    
    init<I: IteratorProtocol>(_ iterator: I) where I.Element == Element {
        self.iterator = AnyIterator(iterator)
        self.buffer = []
    }
    
    mutating func peek() -> Element? {
        if let value = self.iterator.next() {
            self.buffer.append(value)
            return value
        }
        return nil
    }

    mutating func next() -> Element? {
        return self.buffer.popFirst() ?? self.iterator.next()
    }
}
