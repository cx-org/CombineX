#if swift(>=5.1)

/// Adds a `Publisher` to a property.
///
/// Properties annotated with `@Published` contain both the stored value and a publisher which sends any
/// new values after the property value has been sent. New subscribers will receive the current value of the
/// property first.
///
/// Note that the `@Published` property is class-constrained. Use it with properties of classes, not with
/// non-class types like structures.
@propertyWrapper public struct Published<Value> {

    /// Initialize the storage of the Published property as well as the corresponding `Publisher`.
    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    public init(initialValue: Value) {
        self.init(wrappedValue: initialValue)
    }

    /// The current value of the property.
    public var wrappedValue: Value {
        get { return self.value }
        set {
            self.objectWillChange?.send()
            self.publisher?.subject.send(newValue)
            self.value = newValue
        }
    }

    private var value: Value
    
    private var publisher: Publisher?
    
    var objectWillChange: ObservableObjectPublisher?
    
    /// A publisher for properties marked with the `@Published` attribute.
    public struct Publisher: CombineX.Publisher {

        public typealias Output = Value

        public typealias Failure = Never
        
        let subject: CurrentValueSubject<Value, Never>
        
        init(value: Value) {
            self.subject = CurrentValueSubject<Value, Never>(value)
        }

        public func receive<S: Subscriber>(subscriber: S) where Value == S.Input, S.Failure == Published<Value>.Publisher.Failure {
            self.subject.receive(subscriber: subscriber)
        }
    }

    /// The property that can be accessed with the `$` syntax and allows access to the `Publisher`
    public var projectedValue: Published<Value>.Publisher {
        mutating get {
            if let pub = self.publisher {
                return pub
            } else {
                let pub = Publisher(value: self.value)
                self.publisher = pub
                return pub
            }
        }
    }
}

protocol _PublishedProtocol {
    var objectWillChange: ObservableObjectPublisher? { get set }
}

extension _PublishedProtocol {
    
    static func getPublisher(for ptr: UnsafeMutableRawPointer) -> ObservableObjectPublisher? {
        return ptr.assumingMemoryBound(to: Self.self)
            .pointee
            .objectWillChange
    }
    
    static func setPublisher(_ publisher: ObservableObjectPublisher, on ptr: UnsafeMutableRawPointer) {
        ptr.assumingMemoryBound(to: Self.self)
            .pointee
            .objectWillChange = publisher
    }
}

extension Published: _PublishedProtocol {}

#endif
