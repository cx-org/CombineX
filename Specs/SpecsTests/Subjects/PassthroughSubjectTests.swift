import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class PassthroughSubjectTests: XCTestCase {
    
    private typealias Sut = PassthroughSubject<Int, TestingError>
    
    // Reactive Streams Spec: Rules #1, #2, #9
    func testRequestingDemand() {
        
        let initialDemands: [Subscribers.Demand] = [
            .max(0),
            .max(1),
            .max(2),
            .max(10),
            .unlimited
        ]
        
        let subsequentDemands: [[Subscribers.Demand]] = [
            Array(repeating: .max(0), count: 5),
            Array(repeating: .max(1), count: 10),
            [.max(1), .max(0), .max(1), .max(0)],
            [.max(0), .max(1), .max(2)],
            [.unlimited, .max(1)]
        ]
        
        var numberOfInputsHistory: [Int] = []
        let expectedNumberOfInputsHistory = [
            0, 0, 0, 0, 0, 1, 11, 2, 1, 20, 2, 12, 4, 5, 20, 10, 20, 12, 13, 20, 20,
            20, 20, 20, 20
        ]
        
        for initialDemand in initialDemands {
            for subsequentDemand in subsequentDemands {
                
                var subscriptions: [Subscription] = []
                var inputs: [Int] = []
                var completions: [Subscribers.Completion<TestingError>] = []
                
                var i = 0
                
                let passthrough = Sut()
                let subscriber = AnySubscriber<Int, TestingError>(
                    receiveSubscription: { subscription in
                        subscriptions.append(subscription)
                        subscription.request(initialDemand)
                },
                    receiveValue: { value in
                        defer { i += 1 }
                        inputs.append(value)
                        return i < subsequentDemand.endIndex ? subsequentDemand[i] : .none
                },
                    receiveCompletion: { completion in
                        completions.append(completion)
                }
                )
                
                XCTAssertEqual(subscriptions.count, 0)
                XCTAssertEqual(inputs.count, 0)
                XCTAssertEqual(completions.count, 0)
                
                passthrough.subscribe(subscriber)
                
                XCTAssertEqual(subscriptions.count, 1)
                XCTAssertEqual(inputs.count, 0)
                XCTAssertEqual(completions.count, 0)
                
                for j in 0..<20 {
                    passthrough.send(j)
                }
                
                passthrough.send(completion: .finished)
                
                XCTAssertEqual(subscriptions.count, 1)
                XCTAssertEqual(completions.count, 1)
                
                numberOfInputsHistory.append(inputs.count)
            }
        }
        
        XCTAssertEqual(numberOfInputsHistory, expectedNumberOfInputsHistory)
    }
    
    func testMultipleSubscriptions() {
        
        let passthrough = Sut()
        
        final class MySubscriber: Subscriber {
            typealias Input = Sut.Output
            typealias Failure = Sut.Failure
            
            let sut: Sut
            
            var subscriptions: [Subscription] = []
            var inputs: [Int] = []
            var completions: [Subscribers.Completion<TestingError>] = []
            
            init(sut: Sut) {
                self.sut = sut
            }
            
            func receive(subscription: Subscription) {
                subscription.request(.unlimited)
                subscriptions.append(subscription)
                
                if subscriptions.count < 10 {
                    // This must recurse
                    sut.subscribe(self)
                }
            }
            
            func receive(_ input: Input) -> Subscribers.Demand {
                inputs.append(input)
                return .none
            }
            
            func receive(completion: Subscribers.Completion<Failure>) {
                completions.append(completion)
            }
        }
        
        let subscriber = MySubscriber(sut: passthrough)
        
        passthrough.subscribe(subscriber)
        
        XCTAssertEqual(subscriber.subscriptions.count, 10)
        XCTAssertEqual(subscriber.inputs.count, 0)
        XCTAssertEqual(subscriber.completions.count, 0)
        
        passthrough.subscribe(subscriber)
        
        XCTAssertEqual(subscriber.subscriptions.count, 11)
        XCTAssertEqual(subscriber.inputs.count, 0)
        XCTAssertEqual(subscriber.completions.count, 0)
    }
    
    // Reactive Streams Spec: Rule #6
    func testMultipleCompletions() {
        
        var subscriptions: [Subscription] = []
        var inputs: [Int] = []
        var completions: [Subscribers.Completion<TestingError>] = []
        
        let passthrough = Sut()
        let subscriber = AnySubscriber<Int, TestingError>(
            receiveSubscription: { subscription in
                subscriptions.append(subscription)
                subscription.request(.unlimited)
        },
            receiveValue: { value in
                inputs.append(value)
                return .none
        },
            receiveCompletion: { completion in
                passthrough.send(completion: .failure("must not recurse"))
                completions.append(completion)
        }
        )
        
        passthrough.subscribe(subscriber)
        passthrough.send(42)
        
        XCTAssertEqual(subscriptions.count, 1)
        XCTAssertEqual(inputs.count, 1)
        XCTAssertEqual(completions.count, 0)
        
        passthrough.send(completion: .finished)
        
        XCTAssertEqual(subscriptions.count, 1)
        XCTAssertEqual(inputs.count, 1)
        XCTAssertEqual(completions.count, 1)
        
        passthrough.send(completion: .finished)
        
        XCTAssertEqual(subscriptions.count, 1)
        XCTAssertEqual(inputs.count, 1)
        XCTAssertEqual(completions.count, 1)
        
        passthrough.send(completion: .failure("oops"))
        
        XCTAssertEqual(subscriptions.count, 1)
        XCTAssertEqual(inputs.count, 1)
        XCTAssertEqual(completions.count, 1)
    }
    
    // Reactive Streams Spec: Rule #6
    func testValuesAfterCompletion() {
        var subscriptions: [Subscription] = []
        var inputs: [Int] = []
        var completions: [Subscribers.Completion<TestingError>] = []
        
        let passthrough = Sut()
        let subscriber = AnySubscriber<Int, TestingError>(
            receiveSubscription: { subscription in
                subscriptions.append(subscription)
                subscription.request(.unlimited)
        },
            receiveValue: { value in
                inputs.append(value)
                return .none
        },
            receiveCompletion: { completion in
                passthrough.send(42)
                completions.append(completion)
        }
        )
        
        passthrough.subscribe(subscriber)
        
        passthrough.send(42)
        
        XCTAssertEqual(subscriptions.count, 1)
        XCTAssertEqual(inputs.count, 1)
        XCTAssertEqual(completions.count, 0)
        
        passthrough.send(completion: .finished)
        
        XCTAssertEqual(subscriptions.count, 1)
        XCTAssertEqual(inputs.count, 1)
        XCTAssertEqual(completions.count, 1)
        
        passthrough.send(42)
        
        XCTAssertEqual(subscriptions.count, 1)
        XCTAssertEqual(inputs.count, 1)
        XCTAssertEqual(completions.count, 1)
    }
    
    func testLifecycle() {
        
        var deinitCounter = 0
        
        let onDeinit = { deinitCounter += 1 }
        
        do {
            let passthrough = Sut()
            let emptySubscriber = TrackingSubscriber(onDeinit: onDeinit)
            XCTAssertTrue(emptySubscriber.history.isEmpty)
            passthrough.subscribe(emptySubscriber)
            XCTAssertEqual(emptySubscriber.subscriptions.count, 1)
            passthrough.send(31)
            XCTAssertEqual(emptySubscriber.inputs.count, 0)
            passthrough.send(completion: .failure("failure"))
            XCTAssertEqual(emptySubscriber.completions.count, 1)
        }
        
        XCTAssertEqual(deinitCounter, 1)
        
        do {
            let passthrough = Sut()
            let emptySubscriber = TrackingSubscriber(onDeinit: onDeinit)
            XCTAssertTrue(emptySubscriber.history.isEmpty)
            passthrough.subscribe(emptySubscriber)
            XCTAssertEqual(emptySubscriber.subscriptions.count, 1)
            XCTAssertEqual(emptySubscriber.inputs.count, 0)
            XCTAssertEqual(emptySubscriber.completions.count, 0)
        }
        
        XCTAssertEqual(deinitCounter, 1) // We have a leak
        
        var subscription: Subscription?
        
        do {
            
            let passthrough = Sut()
            let emptySubscriber = TrackingSubscriber(
                receiveSubscription: { subscription = $0; $0.request(.unlimited) },
                onDeinit: onDeinit
            )
            XCTAssertTrue(emptySubscriber.history.isEmpty)
            passthrough.subscribe(emptySubscriber)
            XCTAssertEqual(emptySubscriber.subscriptions.count, 1)
            passthrough.send(31)
            XCTAssertEqual(emptySubscriber.inputs.count, 1)
            XCTAssertEqual(emptySubscriber.completions.count, 0)
            XCTAssertNotNil(subscription)
            
        }
        
        XCTAssertEqual(deinitCounter, 1)
        subscription?.cancel()
        XCTAssertEqual(deinitCounter, 2)
    }
    
    func testSynchronization() {
        
        let subscriptions = Atomic<[Subscription]>([])
        let inputs =  Atomic<[Int]>([])
        let completions = Atomic<[Subscribers.Completion<TestingError>]>([])
        
        let passthrough = Sut()
        let subscriber = AnySubscriber<Int, TestingError>(
            receiveSubscription: { subscription in
                subscriptions.do { $0.append(subscription) }
                subscription.request(.unlimited)
        },
            receiveValue: { value in
                inputs.do { $0.append(value) }
                return .none
        },
            receiveCompletion: { completion in
                completions.do { $0.append(completion) }
        }
        )
        
        race(
            {
                passthrough.subscribe(subscriber)
        },
            {
                passthrough.subscribe(subscriber)
        }
        )
        
        XCTAssertEqual(subscriptions.count, 200)
        
        race(
            {
                passthrough.send(31)
        },
            {
                passthrough.send(42)
        }
        )
        
        XCTAssertEqual(inputs.count, 40000)
        
        race(
            {
                subscriptions[0].request(.max(4))
        },
            {
                subscriptions[0].request(.max(10))
        }
        )
        
        race(
            {
                passthrough.send(completion: .finished)
        },
            {
                passthrough.send(completion: .failure(""))
        }
        )
        
        XCTAssertEqual(completions.count, 200)
    }

}

struct TestingError: Error, Hashable, CustomStringConvertible {
    let description: String
    
    static func == (lhs: TestingError, rhs: String) -> Bool {
        lhs.description == rhs
    }
    
    static func == (lhs: String, rhs: TestingError) -> Bool {
        lhs == rhs.description
    }
    
    static func != (lhs: TestingError, rhs: String) -> Bool {
        !(lhs == rhs)
    }
    
    static func != (lhs: String, rhs: TestingError) -> Bool {
        !(lhs == rhs)
    }
}

extension TestingError: LocalizedError {
    var errorDescription: String? { description }
}

extension TestingError: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.init(description: value)
    }
}

func race(times: Int = 100, _ bodies: () -> Void...) {
    
    let queues = bodies.indices.lazy.map {
        DispatchQueue(label: "exectuteConcurrently helper queue #\($0)")
    }
    
    let group = DispatchGroup()
    
    for (body, queue) in zip(bodies, queues) {
        queue.async(group: group) {
            for _ in 0..<times {
                body()
            }
        }
    }
    
    group.wait()
}

@dynamicMemberLookup
final class Atomic<T> {
    private let _q = DispatchQueue(label: "Atomic", attributes: .concurrent)
    
    private var _value: T
    
    init(_ initialValue: T) {
        _value = initialValue
    }
    
    var value: T {
        _q.sync { _value }
    }
    
    func `do`(_ body: (inout T) -> Void) {
        _q.sync(flags: .barrier) {
            body(&_value)
        }
    }
    
    subscript<U>(dynamicMember kp: KeyPath<T, U>) -> U {
        value[keyPath: kp]
    }
}

@available(macOS 10.15, *)
typealias TrackingSubscriber = TrackingSubscriberBase<TestingError>

@available(macOS 10.15, *)
final class TrackingSubscriberBase<E: Error>: Subscriber, CustomStringConvertible {
    
    enum Event: Equatable {
        case subscription(Subscription)
        case value(Int)
        case completion(Subscribers.Completion<E>)
        
        static func == (lhs: Event, rhs: Event) -> Bool {
            switch (lhs, rhs) {
            case (.subscription, .subscription):
                return true
            case let (.value(lhs), .value(rhs)):
                return lhs == rhs
            case let (.completion(lhs), .completion(rhs)):
                switch (lhs, rhs) {
                case (.finished, .finished):
                    return true
                case let (.failure(lhs), .failure(rhs)):
                    return (lhs as? TestingError) == (rhs as? TestingError)
                default:
                    return false
                }
            default:
                return false
            }
        }
    }
    
    private let _receiveSubscription: ((Subscription) -> Void)?
    private let _receiveValue: ((Input) -> Subscribers.Demand)?
    private let _receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)?
    private let _onDeinit: (() -> Void)?
    
    private(set) var history: [Event] = []
    
    var subscriptions: LazyMapSequence<
        LazyFilterSequence<LazyMapSequence<[Event], Subscription?>>, Subscription
        > {
        history.lazy.compactMap {
            if case .subscription(let s) = $0 {
                return s
            } else {
                return nil
            }
        }
    }
    
    var inputs: LazyMapSequence<
        LazyFilterSequence<LazyMapSequence<[Event], Int?>>, Int
        > {
        history.lazy.compactMap {
            if case .value(let v) = $0 {
                return v
            } else {
                return nil
            }
        }
    }
    
    var completions: LazyMapSequence<
        LazyFilterSequence<
        LazyMapSequence<[Event], Subscribers.Completion<E>?>
        >,
        Subscribers.Completion<E>
        > {
        history.lazy.compactMap {
            if case .completion(let c) = $0 {
                return c
            } else {
                return nil
            }
        }
    }
    
    init(receiveSubscription: ((Subscription) -> Void)? = nil,
         receiveValue: ((Input) -> Subscribers.Demand)? = nil,
         receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil,
         onDeinit: (() -> Void)? = nil) {
        _receiveSubscription = receiveSubscription
        _receiveValue = receiveValue
        _receiveCompletion = receiveCompletion
        _onDeinit = onDeinit
    }
    
    func receive(subscription: Subscription) {
        history.append(.subscription(subscription))
        _receiveSubscription?(subscription)
    }
    
    func receive(_ input: Int) -> Subscribers.Demand {
        history.append(.value(input))
        return _receiveValue?(input) ?? .none
    }
    
    func receive(completion: Subscribers.Completion<E>) {
        history.append(.completion(completion))
        _receiveCompletion?(completion)
    }
    
    var description: String {
        "\(type(of: self)): \(history)"
    }
    
    deinit {
        _onDeinit?()
    }
}

@available(macOS 10.15, *)
final class TrackingSubject: Subject {
    
    typealias Failure = TestingError
    
    typealias Output = Int
    
    enum Event: Equatable {
        case subscriber(CombineIdentifier)
        case value(Int)
        case completion(Subscribers.Completion<TestingError>)
        
        static func == (lhs: Event, rhs: Event) -> Bool {
            switch (lhs, rhs) {
            case let (.subscriber(lhs), .subscriber(rhs)):
                return lhs == rhs
            case let (.value(lhs), .value(rhs)):
                return lhs == rhs
            case let (.completion(lhs), .completion(rhs)):
                switch (lhs, rhs) {
                case (.finished, .finished):
                    return true
                case let (.failure(lhs), .failure(rhs)):
                    return lhs == rhs
                default:
                    return false
                }
            default:
                return false
            }
        }
    }
    
    private(set) var history: [Event] = []
    
    func send(_ value: Int) {
        history.append(.value(value))
    }
    
    func send(completion: Subscribers.Completion<TestingError>) {
        history.append(.completion(completion))
    }
    
    func receive<S: Subscriber>(subscriber: S)
        where Failure == S.Failure, Output == S.Input
    {
        history.append(.subscriber(subscriber.combineIdentifier))
    }
}
