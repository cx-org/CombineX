#if canImport(Combine)

import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Output: Publisher, Output.Failure == Never {

    /// Republishes elements sent by the most recently received publisher.
    ///
    /// This operator works with an upstream publisher of publishers, flattening
    /// the stream of elements to appear as if they were coming from a single
    /// stream of elements. It switches the inner publisher as new ones arrive
    /// but keeps the outer publisher constant for downstream subscribers.
    ///
    /// When this operator receives a new publisher from the upstream publisher,
    /// it cancels its previous subscription. Use this feature to prevent
    /// earlier publishers from performing unnecessary work, such as creating
    /// network request publishers from frequently updating user interface
    /// publishers.
    @available(macOS, obsoleted: 11.0)
    @available(iOS, obsoleted: 14.0)
    @available(tvOS, obsoleted: 14.0)
    @available(watchOS, obsoleted: 7.0)
    public func switchToLatest() -> Publishers.SwitchToLatest<Publishers.SetFailureType<Output, Failure>, Publishers.Map<Self, Publishers.SetFailureType<Output, Failure>>> {
        return map { $0.setFailureType(to: Failure.self) }
            .switchToLatest()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Failure == Never, Output: Publisher {

    /// Republishes elements sent by the most recently received publisher.
    ///
    /// This operator works with an upstream publisher of publishers, flattening
    /// the stream of elements to appear as if they were coming from a single
    /// stream of elements. It switches the inner publisher as new ones arrive
    /// but keeps the outer publisher constant for downstream subscribers.
    ///
    /// When this operator receives a new publisher from the upstream publisher,
    /// it cancels its previous subscription. Use this feature to prevent
    /// earlier publishers from performing unnecessary work, such as creating
    /// network request publishers from frequently updating user interface
    /// publishers.
    @available(macOS, obsoleted: 11.0)
    @available(iOS, obsoleted: 14.0)
    @available(tvOS, obsoleted: 14.0)
    @available(watchOS, obsoleted: 7.0)
    public func switchToLatest() -> Publishers.SwitchToLatest<Output, Publishers.SetFailureType<Self, Output.Failure>> {
        return setFailureType(to: Output.Failure.self)
            .switchToLatest()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Failure == Never, Output: Publisher, Output.Failure == Never {

    /// Republishes elements sent by the most recently received publisher.
    ///
    /// This operator works with an upstream publisher of publishers, flattening the stream of elements to appear as if they were coming from a single stream of elements. It switches the inner publisher as new ones arrive but keeps the outer publisher constant for downstream subscribers.
    ///
    /// When this operator receives a new publisher from the upstream publisher, it cancels its previous subscription. Use this feature to prevent earlier publishers from performing unnecessary work, such as creating network request publishers from frequently updating user interface publishers.
    @available(macOS, obsoleted: 11.0)
    @available(iOS, obsoleted: 14.0)
    @available(tvOS, obsoleted: 14.0)
    @available(watchOS, obsoleted: 7.0)
    public func switchToLatest() -> Publishers.SwitchToLatest<Output, Self> {
        return .init(upstream: self)
    }
}

#endif
