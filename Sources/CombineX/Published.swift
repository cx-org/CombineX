#if swift(>=5.1)

extension Publisher where Self.Failure == Never {

    /// Republishes elements received from a publisher, by assigning them to a
    /// property marked as a publisher.
    ///
    /// Use this operator when you want to receive elements from a publisher and
    /// republish them through a property marked with the `@Published` attribute.
    /// The `assign(to:)` operator manages the life cycle of the subscription,
    /// canceling the subscription automatically when the ``Published`` instance
    /// deinitializes. Because of this, the `assign(to:)` operator doesn't
    /// return an ``AnyCancellable`` that you're responsible for like
    /// ``assign(to:on:)`` does.
    ///
    /// The example below shows a model class that receives elements from an
    /// internal `TimerPublisher`, and assigns them to a `@Published` property
    /// called `lastUpdated`:
    ///
    ///     class MyModel: ObservableObject {
    ///             @Published var lastUpdated: Date = Date()
    ///             init() {
    ///                  Timer.publish(every: 1.0, on: .main, in: .common)
    ///                      .autoconnect()
    ///                      .assign(to: $lastUpdated)
    ///             }
    ///         }
    ///
    /// If you instead implemented `MyModel` with
    /// `assign(to: lastUpdated, on: self)`, storing the returned
    /// ``AnyCancellable`` instance could cause a reference cycle, because the
    /// ``Subscribers/Assign`` subscriber would hold a strong reference to
    /// `self`. Using `assign(to:)` solves this problem.
    ///
    /// - Parameter published: A property marked with the `@Published` attribute,
    /// which receives and republishes all elements received from the upstream
    /// publisher.
    public func assign(to published: inout Published<Output>.Publisher) {
        subscribe(PublishedSubscriber(subject: published.subject))
    }
}

/// A type that publishes a property marked with an attribute.
///
/// Publishing a property with the `@Published` attribute creates a publisher of
/// this type. You access the publisher with the `$` operator, as shown here:
///
///     class Weather {
///         @Published var temperature: Double
///         init(temperature: Double) {
///             self.temperature = temperature
///         }
///     }
///
///     let weather = Weather(temperature: 20)
///     cancellable = weather.$temperature
///         .sink() {
///             print ("Temperature now: \($0)")
///     }
///     weather.temperature = 25
///
///     // Prints:
///     // Temperature now: 20.0
///     // Temperature now: 25.0
///
/// When the property changes, publishing occurs in the property's `willSet`
/// block, meaning subscribers receive the new value before it's actually set on
/// the property. In the above example, the second time the sink executes its
/// closure, it receives the parameter value `25`. However, if the closure
/// evaluated `weather.temperature`, the value returned would be `20`.
///
/// > Important: The `@Published` attribute is class constrained. Use it with
/// properties of classes, not with non-class types like structures.
///
/// ### See Also
///
/// - ``Combine/Publisher/assign(to:)``
@propertyWrapper
public struct Published<Value> {

    /// Creates the published instance with an initial wrapped value.
    ///
    /// Don't use this initializer directly. Instead, create a property with
    /// the `@Published` attribute, as shown here:
    ///
    ///     @Published var lastUpdated: Date = Date()
    ///
    /// - Parameter wrappedValue: The publisher's initial value.
    public init(wrappedValue: Value) {
        self.storage = .value(wrappedValue)
    }
    
    /// Creates the published instance with an initial value.
    ///
    /// Don't use this initializer directly. Instead, create a property with the
    /// `@Published` attribute, as shown here:
    ///
    ///     @Published var lastUpdated: Date = Date()
    ///
    /// - Parameter initialValue: The publisher's initial value.
    public init(initialValue: Value) {
        self.init(wrappedValue: initialValue)
    }

    private enum Storage {
        case value(Value)
        case publisher(Publisher)
    }

    private var storage: Storage
    
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

    /// The property for which this instance exposes a publisher.
    ///
    /// The ``Published/projectedValue`` is the property accessed with the
    /// `$` operator.
    public var projectedValue: Published<Value>.Publisher {
        mutating get {
            switch storage {
            case let .value(val):
                let pub = Publisher(value: val)
                storage = .publisher(pub)
                return pub
            case let .publisher(pub):
                return pub
            }
        }
        set {
            switch storage {
            case let .value(val):
                let pub = Publisher(value: val)
                storage = .publisher(pub)
            case .publisher:
                return
            }
        }
    }
    
    /*
     https://github.com/apple/swift/blob/main/test/Interpreter/property_wrappers.swift
     
     https://github.com/apple/swift/commit/8c54db727be2b36643e69c06a43f39410f3a8a9a
     https://github.com/apple/swift/commit/bc2e605b3148857ad7051a98c8cabbd0ee3b1070#diff-16e30c7e9deca1f0874e8fa55b65aa7d24eb9d27d0257c8f3e674c1df0e1da94
     
     > Allow property wrapper types to support a second access pattern for
     instance properties of classes. When supported, the property wrapper's
     static subscript(_enclosingInstance:storage:) is provided with the
     enclosing "self" and a reference-writable key path referring to the
     backing storage property.
     */
    
    public var wrappedValue: Value {
        get {
            fatalError("'wrappedValue' is unavailable: @Published is only available on properties of classes")
        }
        set {
            fatalError("'wrappedValue' is unavailable: @Published is only available on properties of classes")
        }
    }
    
    public static subscript<EnclosingSelf: AnyObject, FinalValue>(
        _enclosingInstance object: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, FinalValue>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>
    ) -> Value {
        get {
            var this: Self {
                get { object[keyPath: storageKeyPath] }
                set { object[keyPath: storageKeyPath] = newValue }
            }
            
            switch this.storage {
            case let .value(val):
                return val
            case let .publisher(pub):
                return pub.subject.value
            }
        }
        set {
            var this: Self {
                get { object[keyPath: storageKeyPath] }
                set { object[keyPath: storageKeyPath] = newValue }
            }
            
            this.objectWillChange?.send()
            
            switch this.storage {
            case .value:
                this.storage = .value(newValue)
            case let .publisher(pub):
                pub.subject.send(newValue)
            }
        }
    }
}

private struct PublishedSubscriber<Value>: Subscriber {

    typealias Input = Value

    typealias Failure = Never

    let combineIdentifier = CombineIdentifier()

    weak var subject: CurrentValueSubject<Value, Never>?

    func receive(subscription: Subscription) {
        subject?.send(subscription: subscription)
        subscription.request(.unlimited)
    }

    func receive(_ input: Value) -> Subscribers.Demand {
        subject?.send(input)
        return .none
    }

    func receive(completion: Subscribers.Completion<Never>) {}
}

#endif
