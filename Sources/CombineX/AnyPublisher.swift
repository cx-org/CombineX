extension Publisher {
    
    /// Wraps this publisher with a type eraser.
    ///
    /// Use `eraseToAnyPublisher()` to expose an instance of AnyPublisher to the downstream subscriber, rather than this publisher’s actual type.
    public func eraseToAnyPublisher() -> AnyPublisher<Output, Failure> {
        return AnyPublisher(self)
    }
}

/// A type-erasing publisher.
///
/// Use `AnyPublisher` to wrap a publisher whose type has details you don’t want to expose to subscribers or other publishers.
public struct AnyPublisher<Output, Failure: Error>: CustomStringConvertible, CustomPlaygroundDisplayConvertible {
    
    @usableFromInline
    let box: PublisherBoxBase<Output, Failure>
    
    /// Creates a type-erasing publisher to wrap the provided publisher.
    ///
    /// - Parameters:
    ///   - publisher: A publisher to wrap with a type-eraser.
    @inlinable
    public init<P: Publisher>(_ publisher: P) where Output == P.Output, Failure == P.Failure {
        box = PublisherBox(publisher)
    }
    
    public var description: String {
        return "AnyPublisher"
    }
    
    public var playgroundDescription: Any {
        return self.description
    }
}

extension AnyPublisher: Publisher {
    
    @inlinable
    public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Failure == S.Failure {
        self.box.receive(subscriber: subscriber)
    }
}

// MARK: - Implementation

@usableFromInline
class PublisherBoxBase<Output, Failure: Error>: Publisher {
    
    @inlinable
    init() {}
    
    @usableFromInline
    func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Failure == S.Failure {
        Never.requiresConcreteImplementation()
    }
}

@usableFromInline
final class PublisherBox<Base: Publisher>: PublisherBoxBase<Base.Output, Base.Failure> {
    
    @usableFromInline
    let base: Base
    
    @inlinable
    init(_ base: Base) {
        self.base = base
    }
    
    @inlinable
    override func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Failure == S.Failure {
        base.receive(subscriber: subscriber)
    }
}
