struct BinaryHeap<T> {
    
    private var nodes = [T]()
    
    private var orderCriteria: (T, T) -> Bool
    
    var isEmpty: Bool {
        return nodes.isEmpty
    }
    
    var count: Int {
        return nodes.count
    }
    
    init(sort: @escaping (T, T) -> Bool) {
        self.orderCriteria = sort
    }
    
    func peek() -> T? {
        return nodes.first
    }
    
    mutating func insert(_ value: T) {
        nodes.append(value)
        shiftUp(nodes.count - 1)
    }
    
    @discardableResult
    mutating func remove() -> T? {
        guard !nodes.isEmpty else { return nil }
        
        if nodes.count == 1 {
            return nodes.removeLast()
        } else {
            let value = nodes[0]
            nodes[0] = nodes.removeLast()
            shiftDown(0)
            return value
        }
    }
    
    @discardableResult
    mutating func remove(where predicate: (T) -> Bool) -> T? {
        guard let index = nodes.firstIndex(where: predicate) else {
            return nil
        }
        let size = nodes.count - 1
        if index != size {
            nodes.swapAt(index, size)
            shiftDown(from: index, until: size)
            shiftUp(index)
        }
        return nodes.removeLast()
    }
    
    private func parentIndex(of index: Int) -> Int {
        return (index - 1) / 2
    }
    
    private func leftChildIndex(of index: Int) -> Int {
        return 2 * index + 1
    }
    
    private func rightChildIndex(of index: Int) -> Int {
        return 2 * index + 2
    }
    
    private mutating func shiftUp(_ index: Int) {
        var childIndex = index
        let child = nodes[childIndex]
        var parentIndex = self.parentIndex(of: childIndex)
        
        while childIndex > 0 && orderCriteria(child, nodes[parentIndex]) {
            nodes[childIndex] = nodes[parentIndex]
            childIndex = parentIndex
            parentIndex = self.parentIndex(of: childIndex)
        }
        
        nodes[childIndex] = child
    }
    
    private mutating func shiftDown(_ index: Int) {
        shiftDown(from: index, until: nodes.count)
    }
    
    private mutating func shiftDown(from index: Int, until endIndex: Int) {
        let leftChildIndex = self.leftChildIndex(of: index)
        let rightChildIndex = leftChildIndex + 1
        
        var first = index
        if leftChildIndex < endIndex && orderCriteria(nodes[leftChildIndex], nodes[first]) {
            first = leftChildIndex
        }
        if rightChildIndex < endIndex && orderCriteria(nodes[rightChildIndex], nodes[first]) {
            first = rightChildIndex
        }
        if first == index { return }
        
        nodes.swapAt(index, first)
        shiftDown(from: first, until: endIndex)
    }
}
