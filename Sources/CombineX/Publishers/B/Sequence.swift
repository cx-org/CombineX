extension Publishers.Sequence where Failure == Never {

    public func min(by areInIncreasingOrder: (Output, Output) -> Bool) -> Optional<Output>.CX.Publisher {
        return .init(self.sequence.min(by: areInIncreasingOrder))
    }

    public func max(by areInIncreasingOrder: (Output, Output) -> Bool) -> Optional<Output>.CX.Publisher {
        return .init(self.sequence.max(by: areInIncreasingOrder))
    }

    public func first(where predicate: (Output) -> Bool) -> Optional<Output>.CX.Publisher {
        return .init(self.sequence.first(where: predicate))
    }
}

extension Publishers.Sequence {
    
    public func allSatisfy(_ predicate: (Output) -> Bool) -> Result<Bool, Failure>.CX.Publisher {
        return .init(self.sequence.allSatisfy(predicate))
    }
  
    public func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Result<Bool, Error>.CX.Publisher {
        return .init(Result {
            try self.sequence.allSatisfy(predicate)
        })
    }
  
    public func collect() -> Result<[Output], Failure>.CX.Publisher {
        return .init(Array(self.sequence))
    }
    
    public func compactMap<T>(_ transform: (Output) -> T?) -> Publishers.Sequence<[T], Failure> {
        return .init(sequence: self.sequence.compactMap(transform))
    }
    
    public func contains(where predicate: (Output) -> Bool) -> Result<Bool, Failure>.CX.Publisher {
        return .init(self.sequence.contains(where: predicate))
    }
    
    public func tryContains(where predicate: (Output) throws -> Bool) -> Result<Bool, Error>.CX.Publisher {
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
    
    public func filter(_ isIncluded: (Output) -> Bool) -> Publishers.Sequence<[Output], Failure> {
        return .init(sequence: self.sequence.filter(isIncluded))
    }
    
    public func ignoreOutput() -> Empty<Output, Failure> {
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
    
    public func reduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Output) -> T) -> Result<T, Failure>.CX.Publisher {
        return .init(self.sequence.reduce(initialResult, nextPartialResult))
    }
  
    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Output) throws -> T) -> Result<T, Error>.CX.Publisher {
        return .init(Result {
            try self.sequence.reduce(initialResult, nextPartialResult)
        })
    }
    
    public func replaceNil<T>(with output: T) -> Publishers.Sequence<[Output], Failure> where Elements.Element == T? {
        return .init(sequence: self.sequence.map { $0 ?? output })
    }
    
    public func scan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Output) -> T) -> Publishers.Sequence<[T], Failure> {
        var r = initialResult
        let s = self.sequence.map { v -> T in
            r = nextPartialResult(r, v)
            return r
        }
        return .init(sequence: s)
    }
    
    public func setFailureType<E>(to error: E.Type) -> Publishers.Sequence<Elements, E> where E : Error {
        return .init(sequence: self.sequence)
    }
}

extension Publishers.Sequence where Elements.Element : Equatable {
    
    public func removeDuplicates() -> Publishers.Sequence<[Output], Failure> {
        var p: Elements.Element?
        let s = self.sequence.compactMap { v -> Elements.Element? in
            defer {
                p = v
            }
            guard let p = p else {
                return v
            }
            return v == p ? nil : v
        }
        return .init(sequence: s)
    }
    
    public func contains(_ output: Elements.Element) -> Result<Bool, Failure>.CX.Publisher {
        return .init(self.sequence.contains(output))
    }
}

extension Publishers.Sequence where Elements.Element : Comparable, Failure == Never {
    
    public func min() -> Optional<Output>.CX.Publisher {
        return .init(self.sequence.min())
    }
    
    public func max() -> Optional<Output>.CX.Publisher {
        return .init(self.sequence.max())
    }
}

extension Publishers.Sequence where Elements : Collection, Failure == Never {
    
    public func first() -> Optional<Output>.CX.Publisher {
        return .init(self.sequence.first)
    }
    
    public func output(at index: Elements.Index) -> Optional<Output>.CX.Publisher {
        return self.sequence.indices.contains(index) ? .init(nil) : .init(self.sequence[index])
    }
}

extension Publishers.Sequence where Elements : Collection {
    
    public func count() -> Result<Int, Failure>.CX.Publisher {
        return .init(self.sequence.count)
    }
    
    public func output(in range: Range<Elements.Index>) -> Publishers.Sequence<[Output], Failure> {
        return .init(sequence: Array(self.sequence[range]))
    }
}

extension Publishers.Sequence where Elements : BidirectionalCollection, Failure == Never {
  
    public func last() -> Optional<Output>.CX.Publisher {
        return .init(self.sequence.last)
    }
    
    public func last(where predicate: (Output) -> Bool) -> Optional<Output>.CX.Publisher {
        return .init(self.sequence.last(where: predicate))
    }
}

extension Publishers.Sequence where Elements : RandomAccessCollection, Failure == Never {
    
    public func output(at index: Elements.Index) -> Optional<Output>.CX.Publisher {
        return .init(self.sequence[index])
    }
}

extension Publishers.Sequence where Elements : RandomAccessCollection {
    
    public func output(in range: Range<Elements.Index>) -> Publishers.Sequence<[Output], Failure> {
        return .init(sequence: Array(self.sequence[range]))
    }
}

extension Publishers.Sequence where Elements : RandomAccessCollection, Failure == Never {

    public func count() -> Just<Int> {
        return .init(self.sequence.count)
    }
}

extension Publishers.Sequence where Elements : RandomAccessCollection {

    public func count() -> Result<Int, Failure>.CX.Publisher {
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
            let s = Inner(sequence: self.sequence, sub: subscriber)
            subscriber.receive(subscription: s)
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
        
        var iterator: PeekableIterator<Elements.Element>
        var state: DemandState = .waiting
        var buffer = Atom(val: Queue<Output>())
        var sub: S?
        
        init(sequence: Elements, sub: S) {
            self.iterator = PeekableIterator(sequence.makeIterator())
            self.sub = sub
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.lock.lock()
            
            switch self.state {
            case .waiting:
                self.state = .demanding(demand)
                
                if demand == .unlimited {
                    self.lock.unlock()
                    self.fastPath()
                } else {
                    self.slowPath(demand)
                }
            case .demanding(let old):
                let new = old + demand
                self.state = .demanding(new)
                
                guard old == 0 else {
                    self.lock.unlock()
                    return
                }
                
                if new == .unlimited {
                    self.lock.unlock()
                    self.fastPath()
                } else {
                    self.slowPath(new)
                }
            case .completed:
                self.lock.unlock()
            }
        }
        
        private func fastPath() {
            while let element = self.iterator.next() {
                guard self.lock.withLockGet(self.state.isDemanding) else {
                    return
                }
                _ = self.sub?.receive(element)
            }

            if self.lock.withLockGet(self.state.complete()) {
                self.sub?.receive(completion: .finished)
                self.sub = nil
            }
        }
        
        private func slowPath(_ demand: Subscribers.Demand) {
            // still locking
            guard demand > 0 else {
                self.lock.unlock()
                return
            }
            
            while let value = self.iterator.next() {
                guard self.state.isDemanding else {
                    self.lock.unlock()
                    return
                }

                _ = self.state.sub(.max(1))
                
                self.buffer.withLockMutating {
                    $0.append(value)
                }
                
                let sub = self.sub!
                self.lock.unlock()
                
                let first = self.buffer.withLockMutating {
                    $0.popFirst()!
                }
                let more = sub.receive(first)
                
                self.lock.lock()
                guard let new = self.state.add(more)?.new, new > 0 else {
                    self.lock.unlock()
                    return
                }
            }
            
            self.state = .completed
            
            let sub = self.sub!
            self.sub = nil
            
            self.lock.unlock()
            
            sub.receive(completion: .finished)
        }
        
        func cancel() {
            self.lock.withLock {
                self.state = .completed
                self.sub = nil
            }
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

    public var cx: AnyCXWrapper<Self> {
        return AnyCXWrapper<Self>(self)
    }
}

extension CombineXWrapper where Base: Sequence {
    
    public var publisher: Publishers.Sequence<Base, Never> {
        return .init(sequence: self.base)
    }
}

