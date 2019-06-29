extension Publishers.Sequence : Equatable where Elements : Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.Sequence<Elements, Failure>, rhs: Publishers.Sequence<Elements, Failure>) -> Bool {
        return lhs.sequence == rhs.sequence
    }
}

extension Publishers.Sequence where Elements : Collection {
    
    public func first() -> Publishers.Optional<Elements.Element, Failure> {
        return .init(self.sequence.first)
    }
}

extension Publishers.Sequence where Elements : Collection {
    
    public func count() -> Publishers.Once<Int, Failure> {
        return .init(self.sequence.count)
    }
}


extension Publishers.Sequence where Elements.Element : Comparable {
    
    public func min() -> Publishers.Optional<Elements.Element, Failure> {
        return .init(self.sequence.min())
    }
    
    public func max() -> Publishers.Optional<Elements.Element, Failure> {
        return .init(self.sequence.max())
    }
}

extension Publishers.Sequence where Elements.Element : Equatable {
    
    public func removeDuplicates() -> Publishers.Sequence<[Publishers.Sequence<Elements, Failure>.Output], Failure> {
        
        let lock = Lock()
        var previous: Elements.Element?
        let newSequence = self.sequence.lazy.compactMap { element -> Elements.Element? in
            lock.withLock {
                defer {
                    previous = element
                }
                guard let prev = previous else {
                    return element
                }
                return element == prev ? nil : element
            }
        }
        return .init(sequence: Array(newSequence))
    }
    
    public func contains(_ output: Elements.Element) -> Publishers.Once<Bool, Failure> {
        return .init(self.sequence.contains(output))
    }
}


extension Publishers.Sequence where Elements : Collection {
    
    public func output(at index: Elements.Index) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        return .init(self.sequence[index])
    }
    
    public func output(in range: Range<Elements.Index>) -> Publishers.Sequence<[Publishers.Sequence<Elements, Failure>.Output], Failure> {
        return .init(sequence: Array(self.sequence[range]))
    }
}

extension Publishers.Sequence where Elements : BidirectionalCollection {
    
    public func last() -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        return .init(self.sequence.last)
    }
    
    public func last(where predicate: (Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        return .init(self.sequence.last(where: predicate))
    }
    
    public func tryLast(where predicate: (Publishers.Sequence<Elements, Failure>.Output) throws -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Error> {
        do {
            let output = try self.sequence.last(where: predicate)
            return .init(output)
        } catch {
            return .init(error)
        }
    }
}

extension Publishers.Sequence where Elements : RandomAccessCollection {
    
    public func output(at index: Elements.Index) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        return .init(self.sequence[index])
    }
    
    public func output(in range: Range<Elements.Index>) -> Publishers.Sequence<[Publishers.Sequence<Elements, Failure>.Output], Failure> {
        return .init(sequence: Array(self.sequence[range]))
    }
}

extension Publishers.Sequence where Elements : RandomAccessCollection {
    
    public func count() -> Publishers.Optional<Int, Failure> {
        return .init(self.sequence.count)
    }
}

extension Publishers.Sequence where Elements : RangeReplaceableCollection {
    
    public func prepend(_ elements: Publishers.Sequence<Elements, Failure>.Output...) -> Publishers.Sequence<Elements, Failure> {
        return .init(sequence: elements + self.sequence)
    }
    
    public func prepend<S>(_ elements: S) -> Publishers.Sequence<Elements, Failure> where S : Sequence, Elements.Element == S.Element {
        return .init(sequence: elements + self.sequence)
    }
    
    public func prepend(_ publisher: Publishers.Sequence<Elements, Failure>) -> Publishers.Sequence<Elements, Failure> {
        return .init(sequence: publisher.sequence + self.sequence)
    }
    
    public func append(_ elements: Publishers.Sequence<Elements, Failure>.Output...) -> Publishers.Sequence<Elements, Failure> {
        return .init(sequence: self.sequence + elements)
    }
    
    public func append<S>(_ elements: S) -> Publishers.Sequence<Elements, Failure> where S : Sequence, Elements.Element == S.Element {
        return .init(sequence: self.sequence + elements)
    }
    
    public func append(_ publisher: Publishers.Sequence<Elements, Failure>) -> Publishers.Sequence<Elements, Failure> {
        return .init(sequence: self.sequence + publisher.sequence)
    }
}

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
            let subscription = Inner(sequence: self.sequence, sub: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Publishers.Sequence {
    
    private final class Inner<S>:
        Subscription,
        CustomStringConvertible,
        CustomDebugStringConvertible
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
                self.drain(demand)
            } else if let demands = self.state.tryAdd(demand), demands.before <= 0 {
                self.drain(demands.after)
            }
        }
        
        private func drain(_ demand: Subscribers.Demand) {
            switch demand {
            case .unlimited:
                self.fastPath()
            case .max(let amount):
                if amount > 0 {
                    self.slowPath(demand)
                }
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
        
        var description: String {
            return "Sequence"
        }
        
        var debugDescription: String {
            return "Sequence"
        }
    }
}

extension Sequence {
    
    public func publisher() -> Publishers.Sequence<Self, Never> {
        return Publishers.Sequence<Self, Never>(sequence: self)
    }
}

