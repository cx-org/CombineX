import CXShim
import CXTestUtility
import Nimble
import Quick

class SwitchToLatestSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }

        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should switch to latest publisher
            it("should switch to latest publisher") {
                let subject1 = PassthroughSubject<Int, Never>()
                let subject2 = PassthroughSubject<Int, Never>()
                
                let subject = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
                
                let pub = subject.switchToLatest()
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject.send(subject1)
                
                subject1.send(1)
                subject1.send(2)
                subject1.send(3)
                
                subject.send(subject2)
                subject1.send(4)
                subject1.send(5)
                subject1.send(6)
                
                subject2.send(7)
                subject2.send(8)
                subject2.send(9)

                let expected = [1, 2, 3, 7, 8, 9].map { TracingSubscriberEvent<Int, Never>.value($0) }
                expect(sub.eventsWithoutSubscription) == expected
            }
            
            // MARK: 1.3 should send failure if a child send failure
            it("should send failure if a child send failure") {
                let subject1 = PassthroughSubject<Int, TestError>()
                let subject2 = PassthroughSubject<Int, TestError>()
                
                let subject = PassthroughSubject<PassthroughSubject<Int, TestError>, TestError>()
                let pub = subject.switchToLatest()
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject.send(subject1)
                subject1.send(completion: .failure(.e0))
                10.times {
                    subject1.send($0)
                }
                
                subject.send(subject2)
                subject2.send(completion: .failure(.e1))
                10.times {
                    subject2.send($0)
                }
                
                expect(sub.eventsWithoutSubscription) == [.completion(.failure(.e0))]
            }
            
            // MARK: 1.4 should relay finish when there are no unfinished children
            it("should relay finish when there are no unfinished children") {
                let subject1 = PassthroughSubject<Int, TestError>()
                let subject2 = PassthroughSubject<Int, TestError>()
                
                let subject = PassthroughSubject<PassthroughSubject<Int, TestError>, TestError>()
                let pub = subject.switchToLatest()
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject.send(subject1)
                subject1.send(completion: .finished)
                expect(sub.eventsWithoutSubscription) == []
                
                subject.send(subject2)
                
                subject2.send(completion: .finished)
                expect(sub.eventsWithoutSubscription) == []
                
                subject.send(completion: .finished)
                expect(sub.eventsWithoutSubscription) == [.completion(.finished)]
            }
        }
        
        // MARK: - Demands
        describe("Demands") {
            
            // MARK: 2.1 should always request .unlimited when subscribing
            it("should always request .unlimited when subscribing") {
                let pub = TestSubject<Just<Int>, Never>()
                
                let sub = pub
                    .switchToLatest()
                    .subscribeTracingSubscriber(initialDemand: .max(10))
                
                pub.send(Just(1))
                pub.send(Just(1))
                
                expect(pub.subscription.requestDemandRecords) == [.unlimited]
                expect(pub.subscription.syncDemandRecords) == [.max(0), .max(0)]
                
                _ = sub
            }
        }
    }
}
