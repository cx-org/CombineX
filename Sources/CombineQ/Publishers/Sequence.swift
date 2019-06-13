extension Publishers {
    
    /// A publisher that publishes a given sequence of elements.
    ///
    /// When the publisher exhausts the elements in the sequence, the next request causes the publisher to finish.
    // REMINDME: There is a bug in combine source code.
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
            let subscription = SequenceSubscription(pub: self, sub: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Publishers.Sequence {
    
    private final class SequenceSubscription<S>:
        CustomSubscription<Publishers.Sequence<Elements, Failure>, S>
    where
        S : Subscriber,
        S.Input == Output,
        S.Failure == Failure
    {
        
        let state = Atomic<State>(value: .waiting)
        
        var elements: Elements
        
        override init(pub: Pub, sub: Sub) {
            self.elements = pub.sequence
            super.init(pub: pub, sub: sub)
        }
        
        override func request(_ demand: Subscribers.Demand) {
            if self.state.compareAndStore(expected: .waiting, newVaue: .subscribing(demand)) {
                
                switch demand {
                case .unlimited:
                    self.fastPath()
                case .max(let amount):
                    if amount > 0 {
                        self.slowPath(demand)
                    }
                }
            } else if let demand = self.state.tryAdd(demand), demand > 0 {
                self.slowPath(demand)
            }
        }
        
        private func fastPath() {
            for element in self.elements {
                if self.state.isFinished {
                    return
                } else {
                    _ = self.sub.receive(element)
                }
            }
            
            if self.state.isFinished {
                return
            }
            self.sub.receive(completion: .finished)
        }
        
        private func slowPath(_ demand: Subscribers.Demand) {
            guard demand > 0 else { return }
            
            var iterator = self.elements.makeIterator()
            
            var totalDemand = demand
            var sended: Subscribers.Demand = .max(0)
            
            while true {
                
                while sended < totalDemand {
                    guard let element = iterator.next() else {
                        if !self.state.isFinished {
                            self.sub.receive(completion: .finished)
                            self.state.store(.finished)
                        }
                        return
                    }
                    
                    if self.state.isFinished {
                        return
                    }
                    if let demand = self.state.tryAdd(self.sub.receive(element)), demand < 0 {
                        return
                    }
                    
                    sended += 1
                }
                
                if let current = self.state.demand {
                    if current <= 0 {
                        return
                    } else {
                        totalDemand = current
                    }
                }
            }
        }
        
        override func cancel() {
            self.state.store(.finished)
        }
    }
}
