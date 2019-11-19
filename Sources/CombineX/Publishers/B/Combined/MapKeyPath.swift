extension Publisher {
    
    /// Returns a publisher that publishes the value of a key path.
    ///
    /// - Parameter keyPath: The key path of a property on `Output`
    /// - Returns: A publisher that publishes the value of the key path.
    public func map<T>(_ keyPath: KeyPath<Output, T>) -> Publishers.MapKeyPath<Self, T> {
        return .init(upstream: self, keyPath: keyPath)
    }
    
    /// Returns a publisher that publishes the values of two key paths as a tuple.
    ///
    /// - Parameters:
    ///   - keyPath0: The key path of a property on `Output`
    ///   - keyPath1: The key path of another property on `Output`
    /// - Returns: A publisher that publishes the values of two key paths as a tuple.
    public func map<T0, T1>(_ keyPath0: KeyPath<Output, T0>, _ keyPath1: KeyPath<Output, T1>) -> Publishers.MapKeyPath2<Self, T0, T1> {
        return .init(upstream: self, keyPath0: keyPath0, keyPath1: keyPath1)
    }

    /// Returns a publisher that publishes the values of three key paths as a tuple.
    ///
    /// - Parameters:
    ///   - keyPath0: The key path of a property on `Output`
    ///   - keyPath1: The key path of another property on `Output`
    ///   - keyPath2: The key path of a third  property on `Output`
    /// - Returns: A publisher that publishes the values of three key paths as a tuple.
    public func map<T0, T1, T2>(_ keyPath0: KeyPath<Output, T0>, _ keyPath1: KeyPath<Output, T1>, _ keyPath2: KeyPath<Output, T2>) -> Publishers.MapKeyPath3<Self, T0, T1, T2> {
        return .init(upstream: self, keyPath0: keyPath0, keyPath1: keyPath1, keyPath2: keyPath2)
    }
}

extension Publishers {

    /// A publisher that publishes the value of a key path.
    public struct MapKeyPath<Upstream: Publisher, Output>: Publisher {

        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The key path of a property to publish.
        public let keyPath: KeyPath<Upstream.Output, Output>

        public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Upstream.Failure == S.Failure {
            self.upstream
                .map {
                    $0[keyPath: self.keyPath]
                }
                .receive(subscriber: subscriber)
        }
    }

    /// A publisher that publishes the values of two key paths as a tuple.
    public struct MapKeyPath2<Upstream: Publisher, Output0, Output1>: Publisher {

        public typealias Output = (Output0, Output1)

        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The key path of a property to publish.
        public let keyPath0: KeyPath<Upstream.Output, Output0>

        /// The key path of a second property to publish.
        public let keyPath1: KeyPath<Upstream.Output, Output1>

        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, S.Input == (Output0, Output1) {
            self.upstream
                .map {
                    ($0[keyPath: self.keyPath0], $0[keyPath: self.keyPath1])
                }
                .receive(subscriber: subscriber)
        }
    }

    /// A publisher that publishes the values of three key paths as a tuple.
    public struct MapKeyPath3<Upstream: Publisher, Output0, Output1, Output2>: Publisher {

        public typealias Output = (Output0, Output1, Output2)

        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The key path of a property to publish.
        public let keyPath0: KeyPath<Upstream.Output, Output0>

        /// The key path of a second property to publish.
        public let keyPath1: KeyPath<Upstream.Output, Output1>

        /// The key path of a third property to publish.
        public let keyPath2: KeyPath<Upstream.Output, Output2>

        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, S.Input == (Output0, Output1, Output2) {
            self.upstream
                .map {
                    (
                        $0[keyPath: self.keyPath0],
                        $0[keyPath: self.keyPath1],
                        $0[keyPath: self.keyPath2]
                    )
                }
                .receive(subscriber: subscriber)
        }
    }
}
