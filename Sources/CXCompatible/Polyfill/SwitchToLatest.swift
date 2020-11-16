#if canImport(Combine)

import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Output: Publisher, Output.Failure == Never {
    
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
    
    @available(macOS, obsoleted: 11.0)
    @available(iOS, obsoleted: 14.0)
    @available(tvOS, obsoleted: 14.0)
    @available(watchOS, obsoleted: 7.0)
    public func switchToLatest() -> Publishers.SwitchToLatest<Output, Self> {
        return .init(upstream: self)
    }
}

#endif
