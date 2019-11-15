import Combine
import CombineX
import CXNamespace

// MARK: - From Combine

extension Combine.Subscription {
    
    public var cx: CXWrappers.AnySubscription {
        return CXWrappers.AnySubscription(wrapping: self)
    }
}

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

extension CombineX.Subscription {
    
    public var ac: ACWrappers.AnySubscription {
        return ACWrappers.AnySubscription(wrapping: self)
    }
}

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
