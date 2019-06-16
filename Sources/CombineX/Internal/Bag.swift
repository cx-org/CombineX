struct BagToken {
    fileprivate let value: UInt64
}

struct Bag<Element> {
    
    private var elements: ContiguousArray<Element>
    private var tokens: ContiguousArray<UInt64>
    
    private var nextToken: BagToken
    
    public init() {
        self.elements = ContiguousArray()
        self.tokens = ContiguousArray()
        self.nextToken = BagToken(value: 0)
    }
    
    public init<S: Sequence>(_ elements: S) where S.Iterator.Element == Element {
        self.elements = ContiguousArray(elements)
        let count = UInt64(self.elements.count)
        self.tokens = ContiguousArray(0..<count)
        self.nextToken = BagToken(value: count)
    }
    
    @discardableResult
    public mutating func insert(_ value: Element) -> BagToken {
        let token = self.nextToken
        self.nextToken = BagToken(value: token.value &+ 1)
        
        self.elements.append(value)
        self.tokens.append(token.value)
        
        return token
    }
    
    @discardableResult
    public mutating func remove(using token: BagToken) -> Element? {
        guard let index = indices.first(where: { self.tokens[$0] == token.value }) else {
            return nil
        }
        
        self.tokens.remove(at: index)
        return self.elements.remove(at: index)
    }
}

extension Bag: RandomAccessCollection {
    
    public var startIndex: Int {
        return self.elements.startIndex
    }
    
    public var endIndex: Int {
        return self.elements.endIndex
    }
    
    public subscript(index: Int) -> Element {
        return self.elements[index]
    }
    
    public func makeIterator() -> Iterator {
        return Iterator(self.elements.makeIterator())
    }
    
    public struct Iterator: IteratorProtocol {
        private var base: ContiguousArray<Element>.Iterator
        
        fileprivate init(_ base: ContiguousArray<Element>.Iterator) {
            self.base = base
        }
        
        public mutating func next() -> Element? {
            return self.base.next()
        }
    }
}
