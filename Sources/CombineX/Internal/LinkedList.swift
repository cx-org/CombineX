struct LinkedList<Element>: BidirectionalCollection, CustomStringConvertible {
    
    final class Node {
        fileprivate var prev: Node?
        fileprivate var next: Node?
        
        let val: Element
        init(val: Element) {
            self.val = val
        }
    }
    
    private var head: Node?
    private var tail: Node?
    
    var isEmpty: Bool {
        return self.head == nil
    }
    
    private(set) var count = 0
    
    mutating func append(_ new: Element) {
        self.count += 1
        
        let node = Node(val: new)
        guard let tail = self.tail else {
            self.head = node
            self.tail = node
            return
        }
        
        tail.next = node
        node.prev = tail
        self.tail = node
    }
    
    mutating func prepend(_ new: Element) {
        self.count += 1
        
        let node = Node(val: new)
        guard let head = self.head else {
            self.head = node
            self.tail = node
            return
        }
        
        node.next = head
        head.prev = node
        self.head = node
    }
    
    private mutating func remove(_ node: Node) {
        self.count -= 1
        
        if let prev = node.prev {
            prev.next = node.next
        } else {
            self.head = node.next
        }
        
        if let next = node.next {
            next.prev = node.prev
        } else {
            self.tail = node.prev
        }
        
        node.prev = nil
        node.next = nil
    }
    
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
        var distance = position.distanceToHead
        
        var node: Node?
        if distance < self.count / 2 {
            node = self.head
            while distance > 0 {
                distance -= 1
                node = node?.next
            }
        } else {
            node = self.tail
            distance += 1
            while distance < self.count {
                distance += 1
                node = node?.prev
            }
        }
        return node!.val
    }
    
    var description: String {
        return Array(self).description
    }
}

extension LinkedList where Element: Equatable {
    
    mutating func remove(_ element: Element) -> Bool {
        var node = self.head
        while let n = node {
            if n.val == element {
                remove(n)
                return true
            }
            node = node?.next
        }
        return false
    }
}
