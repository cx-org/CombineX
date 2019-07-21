#if swift(>=5.1)
/// Adds a `Publisher` to a property.
///
/// Properties annotated with `@Published` contain both the stored value and a publisher which sends any new values after the property value has been sent. New subscribers will receive the current value of the property first.
@propertyWrapper public struct Published<Value> {

    /// Initialize the storage of the Published property as well as the corresponding `Publisher`.
    public init(initialValue: Value) {
        Global.RequiresImplementation()
    }

    /// The current value of the property.
    public var wrappedValue: Value

    public var value: Value
    
    #if !canImport(Combine)
    typealias Publisher = _Publisher
    #endif
    
    // FIXME: See "Result+Publisher.swift"

    public class _Publisher : __Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Value

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Never
        
        let subject: CurrentValueSubject<Value, Never>
        
        init(value: Value) {
            self.subject = CurrentValueSubject<Value, Never>(value)
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Value == S.Input, S : Subscriber, S.Failure == Published<Value>._Publisher.Failure {
            self.subject.receive(subscriber: subscriber)
        }
    }

    public var projectedValue: Published<Value>._Publisher {
        mutating get {
            Global.RequiresImplementation()
        }
    }

    public var delegateValue: Published<Value>._Publisher {
        mutating get {
            Global.RequiresImplementation()
        }
    }
}
#endif
