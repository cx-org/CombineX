import CXShim
import CXTestUtility
import Dispatch
import Nimble
import Quick

class FlatMapSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: Send Values
        describe("Send Values") {
            
            // MARK: 1.1 should send sub-subscriber's value
            it("should send sub-subscriber's value") {
                let sequence = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3])
                
                let pub = sequence
                    .flatMap {
                        Publishers.Sequence<[Int], Never>(sequence: [$0, $0, $0])
                    }
                
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                let events = [1, 2, 3].flatMap { [$0, $0, $0] }.map(TracingSubscriber<Int, Never>.Event.value)
                let expected = events + [.completion(.finished)]
                expect(sub.eventsWithoutSubscription) == expected
            }
            
            // MARK: 1.2 should send values as demand
            it("should send values as demand") {
                let sequence = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3, 4, 5])
                
                let pub = sequence
                    .flatMap {
                        Publishers.Sequence<[Int], Never>(sequence: [$0, $0, $0])
                    }
                    .flatMap {
                        Publishers.Sequence<[Int], Never>(sequence: [$0, $0, $0])
                    }
                
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(10)) { v in
                    [1, 5].contains(v) ? .max(1) : .none
                }
                
                expect(sub.eventsWithoutSubscription.count) == 19
            }
            
            // MARK: 1.3 should complete when a sub-publisher sends an error
            it("should complete when a sub-publisher sends an error") {
                let sequence = Publishers.Sequence<[Int], TestError>(sequence: [0, 1, 2])
                
                let subjects = [
                    PassthroughSubject<Int, TestError>(),
                    PassthroughSubject<Int, TestError>(),
                    PassthroughSubject<Int, TestError>(),
                ]
                
                let pub = sequence
                    .flatMap {
                        subjects[$0]
                    }
                
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                3.times {
                    subjects[0].send(0)
                    subjects[1].send(1)
                    subjects[2].send(2)
                }
                
                subjects[1].send(completion: .failure(.e1))
                
                expect(sub.eventsWithoutSubscription.count) == 10
                
                var events = [0, 1, 2].flatMap { _ in [0, 1, 2] }.map(TracingSubscriber<Int, TestError>.Event.value)
                events.append(.completion(.failure(.e1)))
                
                expect(sub.eventsWithoutSubscription) == events
            }
            
            // MARK: 1.4 should buffer one output for each sub-publisher if there is no demand
            it("should buffer one output for each sub-publisher if there is no demand") {
                let subjects = [
                    PassthroughSubject<Int, Never>(),
                    PassthroughSubject<Int, Never>()
                ]
                let pub = Publishers.Sequence<[Int], Never>(sequence: [0, 1]).flatMap { subjects[$0] }
                let sub = pub.subscribeTracingSubscriber(initialDemand: nil)
                
                subjects[0].send(0)
                subjects[1].send(0)
                
                subjects[0].send(1)
                subjects[1].send(1)
                
                sub.subscription?.request(.max(2))
                
                subjects[1].send(2)
                subjects[0].send(3)
                subjects[1].send(4)
                subjects[0].send(5)
                
                sub.subscription?.request(.unlimited)
                
                expect(sub.eventsWithoutSubscription) == [.value(0), .value(0), .value(2), .value(3)]
            }
        }
        
        // MARK: - Concurrent
        describe("Concurrent") {
            
            // MARK: 2.1 should send as many values ad demand event if there are sent concurrently
            it("should send as many values ad demand event if there are sent concurrently") {
                let sequence = Publishers.Sequence<[Int], Never>(sequence: Array(0..<100))
                
                var subjects: [PassthroughSubject<Int, Never>] = []
                for _ in 0..<100 {
                    subjects.append(PassthroughSubject<Int, Never>())
                }
                
                let pub = sequence.flatMap { i -> PassthroughSubject<Int, Never> in
                    return subjects[i]
                }
                
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(10))
                
                DispatchQueue.global().concurrentPerform(iterations: 100) { i in
                    subjects[i].send(i)
                }
                
                expect(sub.eventsWithoutSubscription.count) == 10
            }
        }
        
        // MARK: - Overloads
        describe("Overloads") {
            
            it("convenient overloads for setting failure type") {
                _ = Just(0).flatMap { _ in Fail<Bool, TestError>(error: .e0) }
                _ = Fail<Bool, TestError>(error: .e0).flatMap { _ in Just(0) }
                _ = Just(0).flatMap { _ in Just("") }
            }
        }
    }
}
