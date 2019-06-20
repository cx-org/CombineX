extension Publishers {
    
    /// A publisher that publishes a given sequence of elements.
    ///
    /// When the publisher exhausts the elements in the sequence, the next request causes the publisher to finish.
    public struct Sequence<Elements, Failure> : Publisher where Elements : Swift.Sequence, Failure : Error {
        
        /// The kind of values published by this publisher.
        public typealias Output = Elements.Element
        
        /// The sequence of elements to publish.
        public let sequence: Elements
        
        /// Creates a publisher for a sequence of elements.
        ///
        /// - Parameter sequence: The sequence of elements to publish.
        public init(sequence: Elements) {
            self.sequence = sequence
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Failure == S.Failure, S : Subscriber, Elements.Element == S.Input {
            let subscription = SequenceSubscription(sequence: self.sequence, sub: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Publishers.Sequence {
    
    private final class SequenceSubscription<S>:
        Subscription
    where
        S : Subscriber,
        S.Input == Output,
        S.Failure == Failure
    {
        
        let state = Atomic<SubscriptionState>(value: .waiting)
        
        var iterator: PeekableIterator<Elements.Element>
        var sub: S?
        
        init(sequence: Elements, sub: S) {
            self.iterator = PeekableIterator(sequence.makeIterator())
            self.sub = sub
        }
        
        func request(_ demand: Subscribers.Demand) {
            if self.state.compareAndStore(expected: .waiting, newVaue: .subscribing(demand)) {
                
                switch demand {
                case .unlimited:
                    self.fastPath()
                case .max(let amount):
                    if amount > 0 {
                        self.slowPath(demand)
                    }
                }
            } else if let demand = self.state.tryAdd(demand), demand.before <= 0 {
                self.slowPath(demand.after)
            }
        }
        
        private func fastPath() {
            while let element = self.iterator.next() {
                guard self.state.isSubscribing else {
                    return
                }
                
                _ = self.sub?.receive(element)
            }

            if self.state.isSubscribing {
                self.sub?.receive(completion: .finished)
                self.state.store(.finished)
                self.sub = nil
            }
        }
        
        private func slowPath(_ demand: Subscribers.Demand) {
            var totalDemand = demand
            while totalDemand > 0 {
                guard let element = self.iterator.next() else {
                    if self.state.finishIfSubscribing() {
                        self.sub?.receive(completion: .finished)
                        self.sub = nil
                    }
                    return
                }
                
                guard self.state.isSubscribing else {
                    return
                }
                
                let demand = self.sub?.receive(element) ?? .none
                guard let currentDemand = self.state.tryAdd(demand - 1)?.after, currentDemand > 0 else {
                    
                    if self.iterator.peek() == nil {
                        if self.state.finishIfSubscribing() {
                            self.sub?.receive(completion: .finished)
                            self.sub = nil
                        }
                    }
                    
                    return
                }
                
                totalDemand = currentDemand
                
                if totalDemand == .unlimited {
                    self.fastPath()
                    return
                }
            }
        }
        
        func cancel() {
            self.state.store(.finished)
            self.sub = nil
        }
    }
}

extension Sequence {
    
    public func publisher() -> Publishers.Sequence<Self, Never> {
        return Publishers.Sequence<Self, Never>(sequence: self)
    }
}

