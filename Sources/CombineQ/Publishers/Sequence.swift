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
            Global.Unimplemented()
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
        
        var iterator: Elements.Iterator
        
        override init(pub: Pub, sub: Sub) {
            self.iterator = pub.sequence.makeIterator()
            super.init(pub: pub, sub: sub)
        }
        
        override func request(_ demand: Subscribers.Demand) {
            switch self.state.load() {
            case .waiting:
                self.state.store(.subscribing(demand))
                if demand > 0 {
                    if let next = iterator.next() {
                        let d = self.sub.receive(next)
//                        self.state.
                    } else {
                        self.sub.receive(completion: .finished)
                    }
                }
            default:
                break
            }
            self.state.write { __state in
                switch __state {
                case .waiting:
                    __state = .subscribing(demand)
                    if demand > 0 {
                        if let next = iterator.next() {
                            let d = self.sub.receive(next)
                        } else {
                            self.sub.receive(completion: .finished)
                        }
                    }
                default:
                    break
                }
            }
        }
        
        override func cancel() {
            self.state.store(.cancelled)
        }
    }
}
