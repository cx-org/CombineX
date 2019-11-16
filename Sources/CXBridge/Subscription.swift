#if canImport(Combine)

import Combine
import CombineX
import CXNamespace

// MARK: - From Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Combine.Subscription {
    
    public var cx: CXWrappers.AnySubscription {
        return .init(wrapping: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CXWrappers {
    
    public struct AnySubscription: CXWrapper, CombineX.Subscription {
        
        public var base: Combine.Subscription
        
        public init(wrapping base: Self.Base) {
            self.base = base
        }
        
        public func request(_ demand: CombineX.Subscribers.Demand) {
            base.request(demand.ac)
        }
        
        public func cancel() {
            base.cancel()
        }
        
        public var combineIdentifier: CombineX.CombineIdentifier {
            return base.combineIdentifier.cx
        }
    }
}

// MARK: - To Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineX.Subscription {
    
    public var ac: ACWrappers.AnySubscription {
        return .init(wrapping: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension ACWrappers {
    
    public struct AnySubscription: ACWrapper, Combine.Subscription {
        
        public var base: CombineX.Subscription
        
        public init(wrapping base: Base) {
            self.base = base
        }
        
        public func request(_ demand: Combine.Subscribers.Demand) {
            base.request(demand.cx)
        }
        
        public func cancel() {
            base.cancel()
        }
        
        public var combineIdentifier: Combine.CombineIdentifier {
            return base.combineIdentifier.ac
        }
    }
}

#endif
