class WeakHashBox<Value: AnyObject> {
    
    private(set) weak var value: Value?
    
    private var id: ObjectIdentifier
    
    init(_ value: Value) {
        self.value = value
        self.id = ObjectIdentifier(value)
    }
}

extension WeakHashBox: Equatable, Hashable {
    
    static func == (lhs: WeakHashBox<Value>, rhs: WeakHashBox<Value>) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
