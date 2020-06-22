#if !COCOAPODS
import CXUtility
#endif

extension Publisher {
    
    /// Combine elements from another publisher and deliver pairs of elements as tuples.
    ///
    /// The returned publisher waits until both publishers have emitted an event, then delivers the oldest unconsumed event from each publisher together as a tuple to the subscriber.
    /// For example, if publisher `P1` emits elements `a` and `b`, and publisher `P2` emits event `c`, the zip publisher emits the tuple `(a, c)`. It won’t emit a tuple with event `b` until `P2` emits another event.
    /// If either upstream publisher finishes successfuly or fails with an error, the zipped publisher does the same.
    ///
    /// - Parameter other: Another publisher.
    /// - Returns: A publisher that emits pairs of elements from the upstream publishers as tuples.
    public func zip<P: Publisher>(_ other: P) -> Publishers.Zip<Self, P> where Failure == P.Failure {
        return .init(self, other)
    }
    
    /// Combine elements from another publisher and deliver a transformed output.
    ///
    /// The returned publisher waits until both publishers have emitted an event, then delivers the oldest unconsumed event from each publisher together as a tuple to the subscriber.
    /// For example, if publisher `P1` emits elements `a` and `b`, and publisher `P2` emits event `c`, the zip publisher emits the tuple `(a, c)`. It won’t emit a tuple with event `b` until `P2` emits another event.
    /// If either upstream publisher finishes successfuly or fails with an error, the zipped publisher does the same.
    ///
    /// - Parameter other: Another publisher.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that emits pairs of elements from the upstream publishers as tuples.
    public func zip<P: Publisher, T>(_ other: P, _ transform: @escaping (Output, P.Output) -> T) -> Publishers.Map<Publishers.Zip<Self, P>, T> where Failure == P.Failure {
        return self.zip(other).map(transform)
    }
}

extension Publishers.Zip: Equatable where A: Equatable, B: Equatable {}

extension Publishers {
    
    /// A publisher created by applying the zip function to two upstream publishers.
    public struct Zip<A, B>: Publisher where A: Publisher, B: Publisher, A.Failure == B.Failure {
        
        public typealias Output = (A.Output, B.Output)
        
        public typealias Failure = A.Failure
        
        public let a: A
        
        public let b: B
        
        public init(_ a: A, _ b: B) {
            self.a = a
            self.b = b
        }
        
        public func receive<S: Subscriber>(subscriber: S) where B.Failure == S.Failure, S.Input == (A.Output, B.Output) {
            let s = Inner(pub: self, sub: subscriber)
            subscriber.receive(subscription: s)
        }
    }
}

extension Publishers.Zip {

    private final class Inner<S>: Subscription,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        B.Failure == S.Failure,
        S.Input == (A.Output, B.Output) {

        typealias Pub = Publishers.Zip<A, B>
        typealias Sub = S

        let lock = Lock()
        let sub: Sub
        
        enum Source: Int {
            case a = 1
            case b = 2
        }
        
        var childA: Child<A.Output>?
        var childB: Child<B.Output>?
        
        var bufferA: CircularBuffer<A.Output>
        var bufferB: CircularBuffer<B.Output>
        
        var isCompleted = false
        
        init(pub: Pub, sub: Sub) {
            self.sub = sub

            self.bufferA = CircularBuffer()
            self.bufferB = CircularBuffer()
            
            let childA = Child<A.Output>(parent: self, source: .a)
            pub.a.subscribe(childA)
            self.childA = childA
            
            let childB = Child<B.Output>(parent: self, source: .b)
            pub.b.subscribe(childB)
            self.childB = childB
        }
        
        deinit {
            lock.cleanupLock()
        }

        func request(_ demand: Subscribers.Demand) {
            guard demand > 0 else {
                return
            }
            self.lock.lock()
            if self.isCompleted {
                self.lock.unlock()
                return
            }
            
            let childA = self.childA
            let childB = self.childB
            self.lock.unlock()
            
            childA?.request(demand)
            childB?.request(demand)
        }

        func cancel() {
            self.lock.lock()
            self.isCompleted = true
            let (childA, childB) = self.release()
            self.lock.unlock()
            
            childA?.cancel()
            childB?.cancel()
        }
        
        private func release() -> (Child<A.Output>?, Child<B.Output>?) {
            defer {
                self.bufferA = CircularBuffer()
                self.bufferB = CircularBuffer()
                
                self.childA = nil
                self.childB = nil
            }
            return (self.childA, self.childB)
        }
        
        func childReceive(_ value: Any, from source: Source) -> Subscribers.Demand {
            self.lock.lock()
            if self.isCompleted {
                self.lock.unlock()
                return .none
            }
            
            switch source {
            case .a:
                self.bufferA.append(value as! A.Output)
            case .b:
                self.bufferB.append(value as! B.Output)
            }
            
            switch (self.bufferA.first, self.bufferB.first) {
            case (.some(let a), .some(let b)):
                _ = self.bufferA.popFirst()
                _ = self.bufferB.popFirst()
                self.lock.unlock()
                let more = self.sub.receive((a, b))
                self.lock.lock()
                
                let childA = self.childA
                let childB = self.childB
                self.lock.unlock()
                
                if more > 0 {
                    switch source {
                    case .a:
                        childB?.request(more)
                    case .b:
                        childA?.request(more)
                    }                    
                }
                return more
            default:
                self.lock.unlock()
                return .none
            }
        }
        
        func childReceive(completion: Subscribers.Completion<A.Failure>, from source: Source) {
            self.lock.lock()
            if self.isCompleted {
                self.lock.unlock()
                return
            }
            
            self.isCompleted = true
            let (childA, childB) = self.release()
            self.lock.unlock()
            
            childA?.cancel()
            childB?.cancel()
            self.sub.receive(completion: completion)
        }

        var description: String {
            return "Zip"
        }

        var debugDescription: String {
            return "Zip"
        }

        final class Child<Output>: Subscriber {
            
            typealias Parent = Inner
            typealias Input = Output
            typealias Failure = A.Failure
            
            let subscription = LockedAtomic<Subscription?>(nil)
            let parent: Parent
            let source: Source
            
            init(parent: Parent, source: Source) {
                self.parent = parent
                self.source = source
            }
            
            func receive(subscription: Subscription) {
                guard self.subscription.setIfNil(subscription) else {
                    subscription.cancel()
                    return
                }
            }
            
            func receive(_ input: Input) -> Subscribers.Demand {
                guard self.subscription.load() != nil else {
                    return .none
                }
                return self.parent.childReceive(input, from: self.source)
            }
            
            func receive(completion: Subscribers.Completion<Failure>) {
                guard let subscription = self.subscription.exchange(nil) else {
                    return
                }
                
                subscription.cancel()
                self.parent.childReceive(completion: completion, from: self.source)
            }
            
            func cancel() {
                self.subscription.exchange(nil)?.cancel()
            }
            
            func request(_ demand: Subscribers.Demand) {
                self.subscription.load()?.request(demand)
            }
        }
    }
}
