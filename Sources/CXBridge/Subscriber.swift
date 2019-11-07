import Combine
import CombineX
import CXNamespace

// MARK: - From Combine

extension Combine.Subscriber {
    
    public var cx: CombineX.AnySubscriber<Input, Failure> {
        return CombineX.AnySubscriber(
            receiveSubscription: { self.receive(subscription: $0.combine) },
            receiveValue: { self.receive($0).cx },
            receiveCompletion: { self.receive(completion: $0.combine) })
    }
}

// MARK: - To Combine

extension CombineX.Subscriber {
    
    public var combine: Combine.AnySubscriber<Input, Failure> {
        return Combine.AnySubscriber(
            receiveSubscription: { self.receive(subscription: $0.cx) },
            receiveValue: { self.receive($0).combine },
            receiveCompletion: { self.receive(completion: $0.cx) })
    }
}
