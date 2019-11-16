#if canImport(Combine)

import Combine
import CombineX
import CXNamespace

// MARK: - From Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Combine.Publisher {
    
    public var cx: CombineX.AnyPublisher<Output, Failure> {
        return CombineX.Publishers.Bridge(wrapping: self).eraseToAnyPublisher()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineX.Publishers {
    
    struct Bridge<Base: Combine.Publisher>: CXWrapper, CombineX.Publisher {
        
        typealias Output = Base.Output
        typealias Failure = Base.Failure
        
        var base: Base
        
        init(wrapping base: Base) {
            self.base = base
        }
        
        func receive<S: CombineX.Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            base.receive(subscriber: subscriber.ac)
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineX.Publishers.Bridge: CombineX.ConnectablePublisher where Base: Combine.ConnectablePublisher {
    
    func connect() -> CombineX.Cancellable {
        return base.connect().cx
    }
}

// MARK: - To Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineX.Publisher {
    
    public var ac: Combine.AnyPublisher<Output, Failure> {
        return Combine.Publishers.Bridge(wrapping: self).eraseToAnyPublisher()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Combine.Publishers {

    struct Bridge<Base: CombineX.Publisher>: ACWrapper, Combine.Publisher {
        
        typealias Output = Base.Output
        typealias Failure = Base.Failure
        
        var base: Base
        
        init(wrapping base: Base) {
            self.base = base
        }
        
        func receive<S: Combine.Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            base.receive(subscriber: subscriber.cx)
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Combine.Publishers.Bridge: Combine.ConnectablePublisher where Base: CombineX.ConnectablePublisher {
    
    func connect() -> Combine.Cancellable {
        return base.connect().ac
    }
}

#endif
