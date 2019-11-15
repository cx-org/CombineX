import Combine
import CombineX
import CXNamespace

// MARK: - From Combine

extension Combine.Publisher {
    
    public var cx: CombineX.AnyPublisher<Output, Failure> {
        return CombineX.Publishers.Bridge(wrapping: self).eraseToAnyPublisher()
    }
}

extension CombineX.Publishers {
    
    struct Bridge<Base: Combine.Publisher>: CXWrapper, CombineX.Publisher {
        
        typealias Output = Base.Output
        typealias Failure = Base.Failure
        
        var base: Base
        
        init(wrapping base: Base) {
            self.base = base
        }
        
        func receive<S: CombineX.Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            self.base.receive(subscriber: subscriber.ac)
        }
    }
}

extension CombineX.Publishers.Bridge: CombineX.ConnectablePublisher where Base: Combine.ConnectablePublisher {
    
    func connect() -> CombineX.Cancellable {
        return base.connect().cx
    }
}

// MARK: - To Combine

extension CombineX.Publisher {
    
    public var ac: Combine.AnyPublisher<Output, Failure> {
        return Combine.Publishers.Bridge(wrapping: self).eraseToAnyPublisher()
    }
}

extension Combine.Publishers {

    struct Bridge<Base: CombineX.Publisher>: ACWrapper, Combine.Publisher {
        
        typealias Output = Base.Output
        typealias Failure = Base.Failure
        
        var base: Base
        
        init(wrapping base: Base) {
            self.base = base
        }
        
        func receive<S: Combine.Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            self.base.receive(subscriber: subscriber.cx)
        }
    }
}

extension Combine.Publishers.Bridge: Combine.ConnectablePublisher where Base: CombineX.ConnectablePublisher {
    
    func connect() -> Combine.Cancellable {
        return base.connect().ac
    }
}
