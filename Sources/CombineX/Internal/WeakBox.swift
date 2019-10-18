class WeakBox<Value: AnyObject> {
    
    private(set) weak var value: Value?
    
    private var id: ObjectIdentifier
    
    init(_ value: Value) {
        self.value = value
        self.id = ObjectIdentifier(value)
    }
}

extension WeakBox: Equatable, Hashable {
    
    static func == (lhs: WeakBox<Value>, rhs: WeakBox<Value>) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
