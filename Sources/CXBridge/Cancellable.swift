#if canImport(Combine)

import Combine
import CombineX
import CXNamespace

// MARK: - From Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Combine.Cancellable {
    
    public var cx: CombineX.AnyCancellable {
        return .init(cancel)
    }
}

// MARK: - To Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineX.Cancellable {
    
    public var ac: Combine.AnyCancellable {
        return .init(cancel)
    }
}

#endif
