#if canImport(Combine)

import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    
    /// Transforms all elements from an upstream publisher into a new publisher
    /// up to a maximum number of publishers you specify.
    ///
    /// - Parameters:
    ///   - maxPublishers: Specifies the maximum number of concurrent publisher
    ///   subscriptions, or ``Combine/Subscribers/Demand/unlimited`` if
    ///   unspecified.
    ///   - transform: A closure that takes an element as a parameter and
    ///   returns a publisher that produces elements of that type.
    /// - Returns: A publisher that transforms elements from an upstream
    /// publisher into a publisher of that element’s type.
    @available(macOS, obsoleted: 11.0)
    @available(iOS, obsoleted: 14.0)
    @available(tvOS, obsoleted: 14.0)
    @available(watchOS, obsoleted: 7.0)
    public func flatMap<P>(
        maxPublishers: Subscribers.Demand = .unlimited,
        _ transform: @escaping (Output) -> P
    ) -> Publishers.FlatMap<Publishers.SetFailureType<P, Failure>, Self> where P: Publisher, P.Failure == Never {
        return .init(upstream: self, maxPublishers: maxPublishers) {
            transform($0).setFailureType(to: Failure.self)
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Failure == Never {
    
    /// Transforms all elements from an upstream publisher into a new publisher
    /// up to a maximum number of publishers you specify.
    ///
    /// - Parameters:
    ///   - maxPublishers: Specifies the maximum number of concurrent publisher
    ///   subscriptions, or ``Combine/Subscribers/Demand/unlimited`` if
    ///   unspecified.
    ///   - transform: A closure that takes an element as a parameter and
    ///   returns a publisher that produces elements of that type.
    /// - Returns: A publisher that transforms elements from an upstream
    /// publisher into a publisher of that element’s type.
    @available(macOS, obsoleted: 11.0)
    @available(iOS, obsoleted: 14.0)
    @available(tvOS, obsoleted: 14.0)
    @available(watchOS, obsoleted: 7.0)
    public func flatMap<P>(
        maxPublishers: Subscribers.Demand = .unlimited,
        _ transform: @escaping (Output) -> P
    ) -> Publishers.FlatMap<P, Publishers.SetFailureType<Self, P.Failure>> where P: Publisher {
        return setFailureType(to: P.Failure.self)
            .flatMap(maxPublishers: maxPublishers, transform)
    }
    
    /// Transforms all elements from an upstream publisher into a new publisher
    /// up to a maximum number of publishers you specify.
    ///
    /// - Parameters:
    ///   - maxPublishers: Specifies the maximum number of concurrent publisher
    ///   subscriptions, or ``Combine/Subscribers/Demand/unlimited`` if
    ///   unspecified.
    ///   - transform: A closure that takes an element as a parameter and
    ///   returns a publisher that produces elements of that type.
    /// - Returns: A publisher that transforms elements from an upstream
    /// publisher into a publisher of that element’s type.
    @available(macOS, obsoleted: 11.0)
    @available(iOS, obsoleted: 14.0)
    @available(tvOS, obsoleted: 14.0)
    @available(watchOS, obsoleted: 7.0)
    public func flatMap<P>(
        maxPublishers: Subscribers.Demand = .unlimited,
        _ transform: @escaping (Output) -> P
    ) -> Publishers.FlatMap<P, Self> where P: Publisher, P.Failure == Never {
        return .init(upstream: self, maxPublishers: maxPublishers, transform: transform)
    }
}

#endif
