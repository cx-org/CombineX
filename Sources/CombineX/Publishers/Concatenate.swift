extension Publishers.Concatenate : Equatable where Prefix : Equatable, Suffix : Equatable {
    
    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A concatenate publisher to compare for equality.
    ///   - rhs: Another concatenate publisher to compare for equality.
    /// - Returns: `true` if the two publishers’ prefix and suffix properties are equal, `false` otherwise.
    public static func == (lhs: Publishers.Concatenate<Prefix, Suffix>, rhs: Publishers.Concatenate<Prefix, Suffix>) -> Bool {
        return lhs.prefix == rhs.prefix && lhs.suffix == rhs.suffix
    }
}

extension Publishers {
    
    /// A publisher that emits all of one publisher’s elements before those from another publisher.
    public struct Concatenate<Prefix, Suffix> : Publisher where Prefix : Publisher, Suffix : Publisher, Prefix.Failure == Suffix.Failure, Prefix.Output == Suffix.Output {
        
        /// The kind of values published by this publisher.
        public typealias Output = Suffix.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Suffix.Failure
        
        /// The publisher to republish, in its entirety, before republishing elements from `suffix`.
        public let prefix: Prefix
        
        /// The publisher to republish only after `prefix` finishes.
        public let suffix: Suffix
        
        public init(prefix: Prefix, suffix: Suffix) {
            self.prefix = prefix
            self.suffix = suffix
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Suffix.Failure == S.Failure, Suffix.Output == S.Input {
            Global.RequiresImplementation()
//            let subscription = Inner(pub: self, sub: subscriber)
//            self.prefix.subscribe(subscription.child)
        }
    }
}
