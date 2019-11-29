// `ObservableObject` depends on property wrapper(`@Published`), which is only available since Swift 5.1.
#if swift(>=5.1)

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

private protocol PublishedProtocol {
    var objectWillChange: ObservableObjectPublisher? { get set }
}
private extension PublishedProtocol {
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
extension Published: PublishedProtocol {}

extension ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    
    public var objectWillChange: ObservableObjectPublisher {
        var installedPub: ObservableObjectPublisher?
        _ = enumerateClassFields(type: Self.self) { offset, type in
            guard let pType = type as? PublishedProtocol.Type else {
                return true
            }
            let propStorage = Unmanaged
                .passUnretained(self)
                .toOpaque()
                .advanced(by: offset)
            if let pub = pType.getPublisher(for: propStorage) {
                installedPub = pub
                return false
            }
            let pub: ObservableObjectPublisher
            if let installedPub = installedPub {
                pub = installedPub
            } else {
                pub = ObservableObjectPublisher()
                installedPub = pub
            }
            pType.setPublisher(pub, on: propStorage)
            return true
        }
        return installedPub ?? ObservableObjectPublisher()
    }
}

/// The default publisher of an `ObservableObject`.
public final class ObservableObjectPublisher: Publisher {
    
    public typealias Output = Void
    
    public typealias Failure = Never
    
    private let subject = PassthroughSubject<Output, Failure>()

    public init() {
        // Do nothing
    }

    public final func receive<S: Subscriber>(subscriber: S) where S.Failure == ObservableObjectPublisher.Failure, S.Input == ObservableObjectPublisher.Output {
        self.subject.receive(subscriber: subscriber)
    }

    public final func send() {
        self.subject.send()
    }
}

#endif
