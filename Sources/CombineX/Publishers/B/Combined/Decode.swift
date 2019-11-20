extension Publisher {

    /// Decodes the output from upstream using a specified `TopLevelDecoder`.
    /// For example, use `JSONDecoder`.
    public func decode<Item, Coder>(type: Item.Type, decoder: Coder) -> Publishers.Decode<Self, Item, Coder> where Item: Decodable, Coder: TopLevelDecoder, Output == Coder.Input {
        return .init(upstream: self, decoder: decoder)
    }
}

extension Publishers {
    
    public struct Decode<Upstream: Publisher, Output: Decodable, Coder: TopLevelDecoder>: Publisher where Upstream.Output == Coder.Input {

        public typealias Failure = Error

        public let upstream: Upstream
    
        private let decoder: Coder

        public init(upstream: Upstream, decoder: Coder) {
            self.upstream = upstream
            self.decoder = decoder
        }

        public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, S.Failure == Publishers.Decode<Upstream, Output, Coder>.Failure {
            self.upstream
                .tryMap {
                    try self.decoder.decode(Output.self, from: $0)
                }
                .receive(subscriber: subscriber)
        }
    }
}
