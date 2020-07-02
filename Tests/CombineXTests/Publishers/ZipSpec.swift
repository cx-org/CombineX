import CXShim
import CXTestUtility
import Nimble
import Quick

class ZipSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
        
            // MARK: 1.1 should zip of 2
            it("should zip of 2") {
                let subject0 = PassthroughSubject<String, TestError>()
                let subject1 = PassthroughSubject<String, TestError>()
                
                let pub = subject0.zip(subject1, +)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject0.send("0")
                subject0.send("1")
                subject1.send("a")
                
                subject0.send("2")
                subject1.send("b")
                subject1.send("c")
                
                let expected = ["0a", "1b", "2c"]
                    .map(TracingSubscriber<String, TestError>.Event.value)
                expect(sub.eventsWithoutSubscription) == expected
            }
            
            // MARK: 1.2 should zip of 3
            it("should zip of 3") {
                let subject0 = PassthroughSubject<String, TestError>()
                let subject1 = PassthroughSubject<String, TestError>()
                let subject2 = PassthroughSubject<String, TestError>()
                
                let pub = subject0.zip(subject1, subject2, { $0 + $1 + $2 })
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
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
                
                let expected = ["0aA", "1bB", "2cC", "3dD"]
                    .map(TracingSubscriber<String, TestError>.Event.value)
                expect(sub.eventsWithoutSubscription) == expected
            }
            
            // MARK: 1.3 should finish when one sends a finish
            it("should finish when one sends a finish") {
                let subjects = (0..<4).map { _ in PassthroughSubject<Int, TestError>() }
                let pub = subjects[0].zip(subjects[1], subjects[2], subjects[3]) {
                    $0 + $1 + $2 + $3
                }
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                10.times {
                    subjects[$0 % 4].send($0)
                }
                subjects[3].send(completion: .finished)
                expect(sub.eventsWithoutSubscription) == [.value(6), .value(22), .completion(.finished)]
            }
            
            // MARK: 1.4 should fail when one sends an error
            it("should fail when one sends an error") {
                let subjects = (0..<4).map { _ in PassthroughSubject<Int, TestError>() }
                let pub = subjects[0].zip(subjects[1], subjects[2], subjects[3]) {
                    $0 + $1 + $2 + $3
                }
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                10.times {
                    subjects[$0 % 4].send($0)
                }
                subjects[3].send(completion: .failure(.e0))
                expect(sub.eventsWithoutSubscription) == [.value(6), .value(22), .completion(.failure(.e0))]
            }
            
            // MARK: 1.5 should send as many as demands
            it("should send as many as demands") {
                let subject0 = PassthroughSubject<String, TestError>()
                let subject1 = PassthroughSubject<String, TestError>()
                
                var counter = 0
                let pub = subject0.zip(subject1)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(10)) { _ in
                    defer {
                        counter += 1
                    }
                    return [0, 10].contains(counter) ? .max(1) : .none
                }
                
                100.times {
                    subject0.send("\($0)")
                    subject1.send("\($0)")
                }
                
                expect(sub.eventsWithoutSubscription.count) == 12
            }
        }
    }
}
