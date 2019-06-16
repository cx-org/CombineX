extension Publisher where Self.Failure == Never {
    
    /// Assigns the value of a KVO-compliant property from a publisher.
    ///
    /// - Parameters:
    ///   - keyPath: The key path of the property to assign.
    ///   - object: The object on which to assign the value.
    /// - Returns: A cancellable instance; used when you end KVO-based assignment of the key path’s value.
    public func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Self.Output>, on object: Root) -> AnyCancellable {
        let assign = Subscribers.Assign(object: object, keyPath: keyPath)
        self.subscribe(assign)
        return AnyCancellable(assign)
    }
}
