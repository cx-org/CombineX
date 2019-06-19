/// Adds a `Publisher` to a property.
///
/// Properties annotated with `@Published` contain both the stored value and a publisher which sends any new values after the property value has been sent.
@propertyDelegate public struct Published<Value> : Publisher {
    
    /// The kind of values published by this publisher.
    public typealias Output = Value
    
    /// The kind of errors this publisher might publish.
    ///
    /// Use `Never` if this `Publisher` does not publish errors.
    public typealias Failure = Never
    
    /// Initialize the storage of the Published property as well as the corresponding `Publisher`.
    public init(initialValue: Value) {
        Global.RequiresImplementation()
    }
    
    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    public func receive<S>(subscriber: S) where Value == S.Input, S : Subscriber, S.Failure == Published<Value>.Failure {
        Global.RequiresImplementation()
    }
    
    /// The current value of the property.
    public var value: Value
}

