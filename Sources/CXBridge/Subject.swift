#if canImport(Combine)

import Combine
import CombineX
import CXNamespace

// MARK: - From Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Combine.Subject {
    
    public var cx: CXWrappers.AnySubject<Self> {
        return .init(wrapping: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CXWrappers {
    
    public final class AnySubject<Base: Combine.Subject>: CXWrapper, CombineX.Subject {
        
        public typealias Output = Base.Output
        public typealias Failure = Base.Failure
        
        public var base: Base
        
        public init(wrapping base: Base) {
            self.base = base
        }
        
        public func receive<S: CombineX.Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            base.receive(subscriber: subscriber.ac)
        }
        
        public func send(_ value: Output) {
            base.send(value)
        }
        
        public func send(completion: CombineX.Subscribers.Completion<Failure>) {
            base.send(completion: completion.ac)
        }
        
        public func send(subscription: CombineX.Subscription) {
            base.send(subscription: subscription.ac)
        }
    }
}

// MARK: - To Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineX.Subject {
    
    public var ac: ACWrappers.AnySubject<Self> {
        return .init(wrapping: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension ACWrappers {
    
    public final class AnySubject<Base: CombineX.Subject>: ACWrapper, Combine.Subject {
        
        public typealias Output = Base.Output
        public typealias Failure = Base.Failure
        
        public var base: Base
        
        public init(wrapping base: Base) {
            self.base = base
        }
        
        public func receive<S: Combine.Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            base.receive(subscriber: subscriber.cx)
        }
        
        public func send(_ value: Output) {
            base.send(value)
        }
        
        public func send(completion: Combine.Subscribers.Completion<Failure>) {
            base.send(completion: completion.cx)
        }
        
        public func send(subscription: Combine.Subscription) {
            base.send(subscription: subscription.cx)
        }
    }
}

#endif
