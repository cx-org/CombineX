#if USE_COMBINE

#if canImport(Combine)

@_exported import Combine
@_exported import CXCompatible

#if swift(>=5.1)

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public typealias Published = Combine.Published

#endif // swift(>=5.1)

#endif // canImport(Combine)

#elseif USE_COMBINEX // USE_COMBINE

@_exported import CombineX
@_exported import CXFoundation

#if swift(>=5.1)

public typealias Published = CombineX.Published

#endif // swift(>=5.1)

#elseif USE_OPEN_COMBINE

@_exported import OpenCombine
@_exported import OpenCombineDispatch

#if swift(>=5.1)

public typealias Published = OpenCombine.Published

#endif // swift(>=5.1)

#else // USE_COMBINE

#error("Must specify a Combine implementation.")

#endif // USE_COMBINE
