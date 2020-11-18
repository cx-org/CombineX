/// A type of object with a publisher that emits before the object has changed.
///
/// By default an `ObservableObject` will synthesize an `objectWillChange`
/// publisher that emits before any of its `@Published` properties changes:
///
///     class Contact: ObservableObject {
///         @Published var name: String
///         @Published var age: Int
///
///         init(name: String, age: Int) {
///             self.name = name
///             self.age = age
///         }
///
///         func haveBirthday() -> Int {
///             age += 1
///             return age
///         }
///     }
///
///     let john = Contact(name: "John Appleseed", age: 24)
///     john.objectWillChange.sink { _ in print("\(john.age) will change") }
///     print(john.haveBirthday())
///     // Prints "24 will change"
///     // Prints "25"
///
public protocol ObservableObject: AnyObject {

    /// The type of publisher that emits before the object has changed.
    associatedtype ObjectWillChangePublisher: Publisher = ObservableObjectPublisher where ObjectWillChangePublisher.Failure == Never

    /// A publisher that emits before the object has changed.
    var objectWillChange: ObjectWillChangePublisher { get }
}

extension ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    
    public var objectWillChange: ObservableObjectPublisher {
        func getFallbackCachedPub() -> ObservableObjectPublisher {
            return globalObjectWillChangeCache.value(for: self) {
                return ObservableObjectPublisher()
            }
        }
        #if swift(>=5.1)
        let obj = Unmanaged.passUnretained(self).toOpaque()
        var iterator = PublishedFieldsEnumerator(object: obj, type: Self.self).makeIterator()
        guard let first = iterator.next() else {
            return getFallbackCachedPub()
        }
        if let installedPub = first.type.getPublisher(for: first.storage) {
            return installedPub
        }
        let pubToInstall = ObservableObjectPublisher()
        first.type.setPublisher(pubToInstall, on: first.storage)
        while let (storage, type) = iterator.next() {
            type.setPublisher(pubToInstall, on: storage)
        }
        return pubToInstall
        #else
        return getFallbackCachedPub()
        #endif
    }
}

/// The default publisher of an `ObservableObject`.
public final class ObservableObjectPublisher: Publisher {
    
    public typealias Output = Void
    
    public typealias Failure = Never
    
    private let subject = PassthroughSubject<Output, Failure>()

    public init() {}

    public final func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
        self.subject.receive(subscriber: subscriber)
    }

    public final func send() {
        self.subject.send()
    }
}

// MARK: - Helpers

private let globalObjectWillChangeCache = ObservableObjectPublisherCache<AnyObject, ObservableObjectPublisher>()

protocol _ObservableObjectProperty {
    var objectWillChange: ObservableObjectPublisher? { get set }
}

private extension _ObservableObjectProperty {
    
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

extension Published: _ObservableObjectProperty {}
