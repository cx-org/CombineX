import CXShim
import CXTestUtility
import Nimble
import Quick

class CombineLatestSpec: QuickSpec {
 
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should combine latest of 2
            it("should combine latest of 2") {
                let subject0 = PassthroughSubject<String, TestError>()
                let subject1 = PassthroughSubject<String, TestError>()
                
                let pub = subject0.combineLatest(subject1, +)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject0.send("0")
                subject0.send("1")
                subject1.send("a")
                
                subject0.send("2")
                subject1.send("b")
                subject1.send("c")
                
                let expected = ["1a", "2a", "2b", "2c"]
                    .map(TracingSubscriber<String, TestError>.Event.value)
                expect(sub.eventsWithoutSubscription) == expected
            }
            
            // MARK: 1.2 should combine latest of 3
            it("should combine latest of 3") {
                let subject0 = PassthroughSubject<String, TestError>()
                let subject1 = PassthroughSubject<String, TestError>()
                let subject2 = PassthroughSubject<String, TestError>()
                
                let pub = subject0.combineLatest(subject1, subject2, { $0 + $1 + $2 })
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(10))
                
                subject0.send("0")
                subject0.send("1")
                subject0.send("2")
                subject1.send("a")
                subject1.send("b")
                subject2.send("A")

                subject0.send("3")
                subject1.send("c")
                subject1.send("d")
                subject2.send("B")
                subject2.send("C")
                subject2.send("D")
                
                let expected = ["2bA", "3bA", "3cA", "3dA", "3dB", "3dC", "3dD"]
                    .map(TracingSubscriber<String, TestError>.Event.value)
                expect(sub.eventsWithoutSubscription) == expected
            }
            
            // MARK: 1.3 should finish when one sends an error
            it("should finish when one sends an error") {
                let subjects = (0..<4).map { _ in PassthroughSubject<Int, TestError>() }
                let pub = subjects[0].combineLatest(subjects[1], subjects[2], subjects[3]) {
                    $0 + $1 + $2 + $3
                }
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                10.times {
                    subjects[$0 % 4].send($0)
                }
                subjects[3].send(completion: .failure(.e0))
                
                let valueEvents = [6, 10, 14, 18, 22, 26, 30]
                    .map(TracingSubscriber<Int, TestError>.Event.value)
                let expected = valueEvents + [.completion(.failure(.e0))]
                expect(sub.eventsWithoutSubscription) == expected
            }
            
            // MARK: 1.4 should send as many as demands
            it("should send as many as demands") {
                let subject0 = PassthroughSubject<String, TestError>()
                let subject1 = PassthroughSubject<String, TestError>()
                
                var counter = 0
                let pub = subject0.combineLatest(subject1, +)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(10)) { _ in
                    defer { counter += 1 }
                    return [0, 10].contains(counter) ? .max(1) : .none
                }
                
                subject0.send("A")
                subject1.send("A")
                100.times {
                    [subject0, subject1].randomElement()!.send("\($0)")
                }
                
                expect(sub.eventsWithoutSubscription.count) == 12
            }
        }
        
        // MARK: - Backpressure sync
        describe("Backpressure sync") {
            
            // MARK: 2.1
            it("should always return none from sync backpressure") {
                let subject0 = TracingSubject<Int, TestError>()
                let subject1 = TracingSubject<Int, TestError>()
                
                let pub = subject0.combineLatest(subject1, +)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(10))
                
                100.times {
                    [subject0, subject1].randomElement()!.send($0)
                }
                
                let records0 = subject0.subscription.syncDemandRecords
                let records1 = subject1.subscription.syncDemandRecords
                
                expect(records0.allSatisfy({ $0 == .none })) == true
                expect(records1.allSatisfy({ $0 == .none })) == true
                
                _ = sub
            }
        }
    }
}
