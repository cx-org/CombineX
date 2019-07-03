extension Publishers.Sequence {
    
    public func allSatisfy(_ predicate: (Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Once<Bool, Failure> {
        return .init(self.sequence.allSatisfy(predicate))
    }
    
    public func tryAllSatisfy(_ predicate: (Publishers.Sequence<Elements, Failure>.Output) throws -> Bool) -> Publishers.Once<Bool, Error> {
        return .init(Result {
            try self.sequence.allSatisfy(predicate)
        })
    }
    
    public func collect() -> Publishers.Once<[Publishers.Sequence<Elements, Failure>.Output], Failure> {
        return .init(Array(self.sequence))
    }
    
    public func compactMap<T>(_ transform: (Publishers.Sequence<Elements, Failure>.Output) -> T?) -> Publishers.Sequence<[T], Failure> {
        return .init(sequence: self.sequence.compactMap(transform))
    }
    
    public func min(by areInIncreasingOrder: (Publishers.Sequence<Elements, Failure>.Output, Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        return .init(self.sequence.min(by: areInIncreasingOrder))
    }
    
    public func tryMin(by areInIncreasingOrder: (Publishers.Sequence<Elements, Failure>.Output, Publishers.Sequence<Elements, Failure>.Output) throws -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Error> {
        return .init(Result {
            try self.sequence.min(by: areInIncreasingOrder)
        })
    }
    
    public func max(by areInIncreasingOrder: (Publishers.Sequence<Elements, Failure>.Output, Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        return .init(self.sequence.max(by: areInIncreasingOrder))
    }
    
    public func tryMax(by areInIncreasingOrder: (Publishers.Sequence<Elements, Failure>.Output, Publishers.Sequence<Elements, Failure>.Output) throws -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Error> {
        return .init(Result {
            try self.sequence.max(by: areInIncreasingOrder)
        })
    }
    
    public func contains(where predicate: (Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Once<Bool, Failure> {
        return .init(self.sequence.contains(where: predicate))
    }
    
    public func tryContains(where predicate: (Publishers.Sequence<Elements, Failure>.Output) throws -> Bool) -> Publishers.Once<Bool, Error> {
        return .init(Result {
            try self.sequence.contains(where: predicate)
        })
    }
    
    public func drop(while predicate: (Elements.Element) -> Bool) -> Publishers.Sequence<DropWhileSequence<Elements>, Failure> {
        return .init(sequence: self.sequence.drop(while: predicate))
    }
    
    public func dropFirst(_ count: Int = 1) -> Publishers.Sequence<DropFirstSequence<Elements>, Failure> {
        return .init(sequence: self.sequence.dropFirst(count))
    }
    
    public func first(where predicate: (Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        return .init(self.sequence.first(where: predicate))
    }
    
    public func tryFirst(where predicate: (Publishers.Sequence<Elements, Failure>.Output) throws -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Error> {
        return .init(Result {
            try self.sequence.first(where: predicate)
        })
    }
    
    public func filter(_ isIncluded: (Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Sequence<[Publishers.Sequence<Elements, Failure>.Output], Failure> {
        return .init(sequence: self.sequence.filter(isIncluded))
    }
    
    public func ignoreOutput() -> Publishers.Empty<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        return .init(completeImmediately: true)
    }
    
    public func map<T>(_ transform: (Elements.Element) -> T) -> Publishers.Sequence<[T], Failure> {
        return .init(sequence: self.sequence.map(transform))
    }
    
    public func prefix(_ maxLength: Int) -> Publishers.Sequence<PrefixSequence<Elements>, Failure> {
        return .init(sequence: self.sequence.prefix(maxLength))
    }
    
    public func prefix(while predicate: (Elements.Element) -> Bool) -> Publishers.Sequence<[Elements.Element], Failure> {
        return .init(sequence: self.sequence.prefix(while: predicate))
    }
    
    public func reduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Publishers.Sequence<Elements, Failure>.Output) -> T) -> Publishers.Once<T, Failure> {
        return .init(self.sequence.reduce(initialResult, nextPartialResult))
    }
    
    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Publishers.Sequence<Elements, Failure>.Output) throws -> T) -> Publishers.Once<T, Error> {
        return .init(Result {
            try self.sequence.reduce(initialResult, nextPartialResult)
        })
    }
    
    public func replaceNil<T>(with output: T) -> Publishers.Sequence<[Publishers.Sequence<Elements, Failure>.Output], Failure> where Elements.Element == T? {
        return .init(sequence: self.sequence.map { $0 ?? output })
    }
    
    public func scan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Publishers.Sequence<Elements, Failure>.Output) -> T) -> Publishers.Sequence<[T], Failure> {
        var result = initialResult
        return .init(sequence: self.sequence.map({
            result = nextPartialResult(result, $0)
            return result
        }))
    }
    
    public func setFailureType<E>(to error: E.Type) -> Publishers.Sequence<Elements, E> where E : Error {
        return .init(sequence: self.sequence)
    }
}

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
        
        let lock = Lock()
        var state_1: SubscriptionState_1<S>
        var iterator: PeekableIterator<Elements.Element>
        
        let state = Atomic<SubscriptionState>(value: .waiting)
        
        var sub: S?
        
        init(sequence: Elements, sub: S) {
            self.state_1 = .waiting(sub)
            self.iterator = PeekableIterator(sequence.makeIterator())
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.lock.lock()
            guard let (sub, demand) = self.state_1.request(demand) else {
                self.lock.unlock()
                return
            }
            self.lock.unlock()
            
            if self.state.compareAndStore(expected: .waiting, newVaue: .subscribing(demand)) {
                self.drain(demand)
            } else if let demands = self.state.tryAdd(demand), demands.before <= 0 {
                self.drain(demands.after)
            }
        }
        
        private func drain(_ demand: Subscribers.Demand) {
//            switch demand {
//            case .unlimited:
//                self.fastPath()
//            case .max(let amount):
//                if amount > 0 {
//                    self.slowPath(demand)
//                }
//            }
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

