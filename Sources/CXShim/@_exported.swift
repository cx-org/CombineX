#if USE_COMBINEX

@_exported import CombineX
@_exported import CXFoundation

#if swift(>=5.1)

public typealias Published = CombineX.Published

#endif // swift(>=5.1)

#else // USE_COMBINEX

#if canImport(Combine)

@_exported import Combine
@_exported import CXCompatible

#if swift(>=5.1)

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public typealias Published = Combine.Published

#endif // swift(>=5.1)

#endif // canImport(Combine)

#endif // USE_COMBINEX
