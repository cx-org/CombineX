// `ObservableObject` depends on property wrapper(`@Published`), which is only available since Swift 5.1.
#if swift(>=5.1)

import Runtime

/// A type of object with a publisher that emits before the object has changed.
///
/// By default an `ObservableObject` will synthesize an `objectWillChange`
/// publisher that emits before any of its `@Published` properties changes:
///
///     class Contact : ObservableObject {
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
///         }
///     }
///
///     let john = Contact(name: "John Appleseed", age: 24)
///     john.objectWillChange.sink { _ in print("will change") }
///     print(john.haveBirthday)
///     // Prints "will change"
///     // Prints "25"
///
public protocol ObservableObject : AnyObject {

    /// The type of publisher that emits before the object has changed.
    associatedtype ObjectWillChangePublisher : Publisher = ObservableObjectPublisher where Self.ObjectWillChangePublisher.Failure == Never

    /// A publisher that emits before the object has changed.
    var objectWillChange: Self.ObjectWillChangePublisher { get }
}

private protocol PublishedProtocol {
    var objectWillChange: ObservableObjectPublisher? { get set }
}
extension Published: PublishedProtocol {}

extension ObservableObject where Self.ObjectWillChangePublisher == ObservableObjectPublisher {
    
    private static func publishedProperties() throws -> [PropertyInfo] {
        // TODO: cache
        let info = try typeInfo(of: self)
        return info.properties.filter { $0.type is PublishedProtocol.Type }
    }
    
    private func set(objectWillChange: ObservableObjectPublisher, for publishedProperty: PropertyInfo) throws {
        // TODO: mutate in place
        var published = try publishedProperty.get(from: self) as! PublishedProtocol
        published.objectWillChange = objectWillChange
        try withUnsafePointer(to: self) { ptr in
            let mptr = UnsafeMutablePointer(mutating: ptr)
            try publishedProperty.set(value: published, on: &(mptr.pointee))
        }
    }
    
    /// A publisher that emits before the object has changed.
    public var objectWillChange: ObservableObjectPublisher {
        do {
            let publishedProperties = try type(of: self).publishedProperties()
            guard !publishedProperties.isEmpty else {
                // TODO: cache
                return ObservableObjectPublisher()
            }
            if let pub = (try publishedProperties[0].get(from: self) as! PublishedProtocol).objectWillChange {
                return pub
            }
            let pub = ObservableObjectPublisher()
            try publishedProperties.forEach { try set(objectWillChange: pub, for: $0) }
            return pub
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

/// The default publisher of an `ObservableObject`.
final public class ObservableObjectPublisher : Publisher {

    /// The kind of values published by this publisher.
    public typealias Output = Void

    /// The kind of errors this publisher might publish.
    ///
    /// Use `Never` if this `Publisher` does not publish errors.
    public typealias Failure = Never
    
    private let subject = PassthroughSubject<Output, Failure>()

    public init() {
        // Do nothing
    }

    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    final public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == ObservableObjectPublisher.Failure, S.Input == ObservableObjectPublisher.Output {
        self.subject.receive(subscriber: subscriber)
    }

    final public func send() {
        self.subject.send()
    }
}

#endif
