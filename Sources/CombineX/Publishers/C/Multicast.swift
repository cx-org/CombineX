#if !COCOAPODS
import CXUtility
#endif

extension Publisher {
    
    /// Applies a closure to create a subject that delivers elements to subscribers.
    ///
    /// Use a multicast publisher when you have multiple downstream subscribers, but you want upstream publishers to only process one `receive(_:)` call per event.
    /// In contrast with `multicast(subject:)`, this method produces a publisher that creates a separate Subject for each subscriber.
    /// - Parameter createSubject: A closure to create a new Subject each time a subscriber attaches to the multicast publisher.
    public func multicast<S: Subject>(_ createSubject: @escaping () -> S) -> Publishers.Multicast<Self, S> where Failure == S.Failure, Output == S.Output {
        return .init(upstream: self, createSubject: createSubject)
    }
    
    /// Provides a subject to deliver elements to multiple subscribers.
    ///
    /// Use a multicast publisher when you have multiple downstream subscribers, but you want upstream publishers to only process one `receive(_:)` call per event.
    /// In contrast with `multicast(_:)`, this method produces a publisher shares the provided Subject among all the downstream subscribers.
    /// - Parameter subject: A subject to deliver elements to downstream subscribers.
    public func multicast<S: Subject>(subject: S) -> Publishers.Multicast<Self, S> where Failure == S.Failure, Output == S.Output {
        return .init(upstream: self, createSubject: { subject })
    }
}

extension Publishers {
    
    /// A publisher that uses a subject to deliver elements to multiple subscribers.
    public final class Multicast<Upstream, SubjectType>: ConnectablePublisher where Upstream: Publisher, SubjectType: Subject, Upstream.Failure == SubjectType.Failure, Upstream.Output == SubjectType.Output {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public final let upstream: Upstream
        
        /// A closure to create a new Subject each time a subscriber attaches to the multicast publisher.
        public final let createSubject: () -> SubjectType
        
        private lazy var subject: SubjectType = self.createSubject()
        
        private let lock = Lock()
        private var cancellable: Cancellable?
        
        /// Creates a multicast publisher that applies a closure to create a subject that delivers elements to subscribers.
        /// - Parameter upstream: The publisher from which this publisher receives elements.
        /// - Parameter createSubject: A closure to create a new Subject each time a subscriber attaches to the multicast publisher.
        init(upstream: Upstream, createSubject: @escaping () -> SubjectType) {
            self.upstream = upstream
            self.createSubject = createSubject
        }
        
        deinit {
            lock.cleanupLock()
        }
        
        public final func receive<S: Subscriber>(subscriber: S) where SubjectType.Failure == S.Failure, SubjectType.Output == S.Input {
            self.subject.receive(subscriber: subscriber)
        }
        
        public final func connect() -> Cancellable {
            self.lock.lock()
            defer {
                self.lock.unlock()
            }
            
            if let cancel = self.cancellable {
                return cancel
            }
            
            let cancel = self.upstream.subscribe(self.subject)
            self.cancellable = cancel
            return cancel
        }
    }
}
