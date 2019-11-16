#if canImport(Combine)

import Combine
import CombineX
import CXNamespace

// MARK: - From Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Combine.Subscriber {
    
    public var cx: CombineX.AnySubscriber<Input, Failure> {
        return .init(
            receiveSubscription: { self.receive(subscription: $0.ac) },
            receiveValue: { self.receive($0).cx },
            receiveCompletion: { self.receive(completion: $0.ac) })
    }
}

// MARK: - To Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineX.Subscriber {
    
    public var ac: Combine.AnySubscriber<Input, Failure> {
        return .init(
            receiveSubscription: { self.receive(subscription: $0.cx) },
            receiveValue: { self.receive($0).ac },
            receiveCompletion: { self.receive(completion: $0.cx) })
    }
}

#endif
