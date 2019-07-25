extension Publisher {

    /// Decodes the output from upstream using a specified `TopLevelDecoder`.
    /// For example, use `JSONDecoder`.
    public func decode<Item, Coder>(type: Item.Type, decoder: Coder) -> Publishers.Decode<Self, Item, Coder> where Item : Decodable, Coder : TopLevelDecoder, Self.Output == Coder.Input {
        return .init(upstream: self, decoder: decoder)
    }
}

extension Publishers {
    
    public struct Decode<Upstream, Output, Coder> : Publisher where Upstream : Publisher, Output : Decodable, Coder : TopLevelDecoder, Upstream.Output == Coder.Input {

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error

        public let upstream: Upstream
    
        private let decoder: Coder

        public init(upstream: Upstream, decoder: Coder) {
            self.upstream = upstream
            self.decoder = decoder
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, S.Failure == Publishers.Decode<Upstream, Output, Coder>.Failure {
            self.upstream
                .tryMap {
                    try self.decoder.decode(Output.self, from: $0)
                }
                .receive(subscriber: subscriber)
        }
    }

}
