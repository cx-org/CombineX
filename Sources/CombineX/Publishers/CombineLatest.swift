extension Publisher {
    
    /// Subscribes to an additional publisher and publishes a tuple upon receiving output from either publisher.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
    /// All upstream publishers need to finish for this publisher to finsh. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - other: Another publisher to combine with this one.
    /// - Returns: A publisher that receives and combines elements from this and another publisher.
    public func combineLatest<P>(_ other: P) -> Publishers.CombineLatest<Self, P> where P : Publisher, Self.Failure == P.Failure {
        return .init(self, other)
    }
    
    /// Subscribes to an additional publisher and invokes a closure upon receiving output from either publisher.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
    /// All upstream publishers need to finish for this publisher to finsh. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - other: Another publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this and another publisher.
    public func combineLatest<P, T>(_ other: P, _ transform: @escaping (Self.Output, P.Output) -> T) -> Publishers.Map<Publishers.CombineLatest<Self, P>, T> where P : Publisher, Self.Failure == P.Failure {
        return self.combineLatest(other).map(transform)
    }
    
}

extension Publishers.CombineLatest : Equatable where A : Equatable, B : Equatable {
    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A combineLatest publisher to compare for equality.
    ///   - rhs: Another combineLatest publisher to compare for equality.
    /// - Returns: `true` if the corresponding upstream publishers of each combineLatest publisher are equal, `false` otherwise.
    public static func == (lhs: Publishers.CombineLatest<A, B>, rhs: Publishers.CombineLatest<A, B>) -> Bool {
        return lhs.a == rhs.a && lhs.b == rhs.b
    }
}

extension Publishers {
    
    /// A publisher that receives and combines the latest elements from two publishers.
    public struct CombineLatest<A, B> : Publisher where A : Publisher, B : Publisher, A.Failure == B.Failure {
        
        /// The kind of values published by this publisher.
        public typealias Output = (A.Output, B.Output)
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure
        
        public let a: A
        
        public let b: B
        
        public init(_ a: A, _ b: B) {
            self.a = a
            self.b = b
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, B.Failure == S.Failure, S.Input == (A.Output, B.Output) {
            let s = Inner(pub: self, sub: subscriber)
            subscriber.receive(subscription: s)
        }
    }
}


private struct CombineLatestState: OptionSet {
    let rawValue: Int
    
    static let aCompleted = CombineLatestState(rawValue: 1 << 0)
    static let bCompleted = CombineLatestState(rawValue: 1 << 1)
    static let initial: CombineLatestState = []
    static let completed: CombineLatestState = [.aCompleted, .bCompleted]
    
    var isACompleted: Bool {
        return self.contains(.aCompleted)
    }
    
    var isBCompleted: Bool {
        return self.contains(.bCompleted)
    }
    
    var isCompleted: Bool {
        return self == .completed
    }
}
 
extension Publishers.CombineLatest {

    private final class Inner<S>:
        Subscription,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        B.Failure == S.Failure,
        S.Input == (A.Output, B.Output)
    {

        typealias Pub = Publishers.CombineLatest<A, B>
        typealias Sub = S

        let lock = Lock()
        let sub: Sub
        
        var state: CombineLatestState = .initial
        
        var outputA: A.Output?
        var outputB: B.Output?
        
        var childA: Child<A.Output>?
        var childB: Child<B.Output>?

        init(pub: Pub, sub: Sub) {
            self.sub = sub

            let childA = Child<A.Output>(parent: self, index: 0)
            pub.a.subscribe(childA)
            self.childA = childA
            
            let childB = Child<B.Output>(parent: self, index: 1)
            pub.b.subscribe(childB)
            self.childB = childB
        }

        func request(_ demand: Subscribers.Demand) {
            guard demand > 0 else {
                return
            }
            self.lock.lock()
            var a = demand
            if self.outputA.isNotNil {
                a -= 1
            }
            
            var b = demand
            if self.outputB.isNotNil {
                b -= 1
            }
            
            let childA = self.childA
            let childB = self.childB
            self.lock.unlock()
            
            childA?.request(a)
            childB?.request(b)
        }

        func cancel() {
            self.lock.lock()
            self.state = .completed
            let (childA, childB) = self.release()
            self.lock.unlock()
            
            childA?.cancel()
            childB?.cancel()
        }
        
        private func release() -> (Child<A.Output>?, Child<B.Output>?){
            defer {
                self.outputA = nil
                self.outputB = nil
                
                self.childA = nil
                self.childB = nil
            }
            return (self.childA, self.childB)
        }
        
        func childReceive(_ value: Any, from index: Int) -> Subscribers.Demand {
            self.lock.unlock()
            let action = CombineLatestState(rawValue: index + 1)
            if self.state.contains(action) {
                self.lock.unlock()
                return .none
            }
            
            switch index {
            case 0:     self.outputA = value as? A.Output
            case 1:     self.outputB = value as? B.Output
            default:    break
            }
            
            switch (self.outputA, self.outputB) {
            case (.some(let a), .some(let b)):
                self.lock.unlock()
            
                let more = self.sub.receive((a, b))
                self.childA?.request(more)
                self.childB?.request(more)
                return .none
            default:
                self.lock.unlock()
                return .none
            }
        }
        
        func childReceive(completion: Subscribers.Completion<A.Failure>, from index: Int) {
            let action = CombineLatestState(rawValue: index + 1)
            
            self.lock.lock()
            if self.state.contains(action) {
                self.lock.unlock()
                return
            }
            
            switch completion {
            case .failure:
                self.state = .completed
                let (childA, childB) = self.release()
                self.lock.unlock()
                
                childA?.cancel()
                childB?.cancel()
                self.sub.receive(completion: completion)
            case .finished:
                self.state.insert(action)
                if self.state.isCompleted {
                    let (childA, childB) = self.release()
                    self.lock.unlock()
                    
                    childA?.cancel()
                    childB?.cancel()
                    self.sub.receive(completion: completion)
                } else {
                    self.lock.unlock()
                }
            }
        }

        var description: String {
            return "CombineLatest"
        }

        var debugDescription: String {
            return "CombineLatest"
        }

        final class Child<Output>: Subscriber {
            
            typealias Input = Output
            typealias Failure = A.Failure
            
            let subscription = Atom<Subscription?>(val: nil)
            let parent: Inner
            let index: Int
            
            init(parent: Inner, index: Int) {
                self.parent = parent
                self.index = index
            }
            
            func receive(subscription: Subscription) {
                if self.subscription.setIfNil(subscription) {
                    subscription.request(.max(1))
                } else {
                    subscription.cancel()
                }
            }
            
            func receive(_ input: Input) -> Subscribers.Demand {
                guard self.subscription.isNotNil else {
                    return .none
                }
                return self.parent.childReceive(input, from: self.index)
            }
            
            func receive(completion: Subscribers.Completion<Failure>) {
                guard let subscription = self.subscription.exchange(with: nil) else {
                    return
                }
                
                subscription.cancel()
                self.parent.childReceive(completion: completion, from: self.index)
            }
            
            func cancel() {
                self.subscription.exchange(with: nil)?.cancel()
            }
            
            func request(_ demand: Subscribers.Demand) {
                self.subscription.get()?.request(demand)
            }
        }
    }
}

