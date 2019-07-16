struct PeekableIterator<Element>: IteratorProtocol {
    
    private var iterator: AnyIterator<Element>
    
    private var nextValue: Element?
    
    init<I: IteratorProtocol>(_ iterator: I) where I.Element == Element {
        self.iterator = AnyIterator(iterator)
        self.nextValue = self.iterator.next()
    }
    
    var isEmpty: Bool {
        return self.nextValue == nil
    }

    mutating func next() -> Element? {
        defer {
            self.nextValue = self.iterator.next()
        }
        return self.nextValue
    }
}
