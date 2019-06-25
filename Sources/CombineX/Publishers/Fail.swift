extension Publishers {
    
    /// A publisher that immediately terminates with the specified error.
    public struct Fail<Output, Failure> : Publisher where Failure : Error {
        
        /// Creates a publisher that immediately terminates with the specified failure.
        ///
        /// - Parameter error: The failure to send when terminating the publisher.
        public init(error: Failure) {
            self.error = error
        }
        
        /// Creates publisher with the given output type, that immediately terminates with the specified failure.
        ///
        /// Use this initializer to create a `Fail` publisher that can work with subscribers or publishers that expect a given output type.
        /// - Parameters:
        ///   - outputType: The output type exposed by this publisher.
        ///   - failure: The failure to send when terminating the publisher.
        public init(outputType: Output.Type, failure: Failure) {
            self.error = failure
        }
        
        /// The failure to send when terminating the publisher.
        public let error: Failure
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber {
            Publishers.Once(Result<Output, Failure>.failure(self.error)).subscribe(subscriber)
        }
    }
}
