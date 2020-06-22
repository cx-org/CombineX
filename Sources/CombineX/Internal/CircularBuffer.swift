struct CircularBuffer<Element>: BidirectionalCollection, CustomStringConvertible {
    
    private var storage: ContiguousArray<Element?>
    private var head = 0
    private var tail = 0
    
    init(minimumCapacity: Int = 16) {
        self.storage = ContiguousArray(repeating: nil, count: minimumCapacity.nextPowerOf2())
    }
    
    private func index(advance idx: Int, by n: Int) -> Int {
        return (idx + n) & (self.storage.count - 1)
    }
    
    private mutating func advanceHead(by n: Int) {
        self.head = self.index(advance: self.head, by: n)
    }
    
    private mutating func advanceTail(by n: Int) {
        self.tail = self.index(advance: self.tail, by: n)
    }
    
    // MARK: - Properties
    
    var isEmpty: Bool {
        return self.head == self.tail
    }
    
    var count: Int {
        let d = self.tail - self.head
        return d >= 0 ? d : (self.storage.count + d)
    }
    
    var capacity: Int {
        return self.storage.count
    }
    
    // MARK: - Mutating
    
    mutating func append(_ new: Element) {
        self.storage[self.tail] = new
        self.advanceTail(by: 1)
        
        if self.head == self.tail {
            self.increaseCapacity()
        }
    }
    
    mutating func prepend(_ new: Element) {
        self.storage[self.index(advance: self.head, by: -1)] = new
        self.advanceHead(by: -1)
        
        if self.head == self.tail {
            self.increaseCapacity()
        }
    }
    
    private mutating func increaseCapacity() {
        var newStorage: ContiguousArray<Element?> = []
        let oldCapacity = self.storage.count
        let newCapacity = Swift.max(16, oldCapacity << 1)
        
        newStorage.reserveCapacity(newCapacity)
        newStorage.append(contentsOf: self.storage[self.head..<oldCapacity])
        newStorage.append(contentsOf: self.storage[0..<self.head])
        
        let rest = newCapacity - newStorage.count
        newStorage.append(contentsOf: repeatElement(nil, count: rest))
        
        self.head = 0
        self.tail = oldCapacity
        self.storage = newStorage
    }
    
    mutating func popFirst() -> Element? {
        if self.isEmpty {
            return nil
        }
        
        let e = self.storage[self.head]
        self.storage[self.head] = nil
        self.advanceHead(by: 1)
        return e
    }
    
    mutating func popLast() -> Element? {
        if self.isEmpty {
            return nil
        }
        
        self.advanceTail(by: -1)
        let e = self.storage[self.tail]
        self.storage[self.tail] = nil
        return e
    }
    
    // MARK: - Collection
    struct Index: Comparable {
        
        fileprivate let distanceToHead: Int
        
        fileprivate init(distanceToHead: Int) {
            self.distanceToHead = distanceToHead
        }
        
        static func < (a: Index, b: Index) -> Bool {
            return a.distanceToHead < b.distanceToHead
        }
    }
    
    var startIndex: Index {
        return Index(distanceToHead: 0)
    }
    
    var endIndex: Index {
        return Index(distanceToHead: self.count)
    }
    
    func index(after i: Index) -> Index {
        return Index(distanceToHead: i.distanceToHead + 1)
    }
    
    func index(before i: Index) -> Index {
        return Index(distanceToHead: i.distanceToHead - 1)
    }
    
    subscript(position: Index) -> Element {
        assert(self.indices.contains(position), "[CircularBuffer]: CircularBuffer index is out of range.")
        let idx = self.index(advance: self.head, by: position.distanceToHead)
        return self.storage[idx]!
    }
    
    // MARK: - Description
    
    var description: String {
        var desc = ""
        
        for (idx, e) in self.storage.enumerated() {
            var s = e.map { "\($0)" } ?? "_"
            if idx == self.head { s = "<" + s }
            if idx == self.index(advance: self.tail, by: -1) { s = s + ">" }
            
            switch idx {
            case 0:                         desc.append("[" + s + ", ")
            case self.storage.count - 1:    desc.append(s + "]")
            default:                        desc.append(s + ", ")
            }
        }
        
        return desc
    }
}

private extension FixedWidthInteger {
    
    func nextPowerOf2() -> Self {
        if self == 0 { return 1 }
        return 1 << (Self.bitWidth - (self - 1).leadingZeroBitCount)
    }
}
