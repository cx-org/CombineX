import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class SwitchToLatestSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            Resources.release()
        }

        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should switch to latest publisher
            it("should switch to latest publisher") {
                let subject1 = PassthroughSubject<Int, Never>()
                let subject2 = PassthroughSubject<Int, Never>()
                
                let subject = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
                
                let pub = subject.switchToLatest()
                let sub = makeTestSubscriber(Int.self, Never.self, .unlimited)
                pub.subscribe(sub)
                
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

                let expected = [1, 2, 3, 7, 8, 9].map { TestSubscriberEvent<Int, Never>.value($0) }
                expect(sub.events).to(equal(expected))
            }
            
            #if !USE_COMBINE
            // MARK: 1.2 should not crash even if the child sends more events than initial demand.
            it("should not crash even if the child sends more events than initial demand.") {
                let subject1 = PassthroughSubject<Int, Never>()
                
                let subject = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
                
                let pub = subject.switchToLatest()
                let sub = TestSubscriber<Int, Never>(receiveSubscription: { (s) in
                    s.request(.max(10))
                }, receiveValue: { v in
                    return [0, 10].contains(v) ? .max(1) : .none
                }, receiveCompletion: { c in
                })
                pub.subscribe(sub)
                
                subject.send(subject1)
                
                // FIXME: Combine will crash here. This should be a bug.
                11.times {
                    subject1.send($0)
                }
            }
            #endif
            
            // MARK: 1.3 should send failure if a child send failure
            it("should send failure if a child send failure") {
                let subject1 = PassthroughSubject<Int, TestError>()
                let subject2 = PassthroughSubject<Int, TestError>()
                
                let subject = PassthroughSubject<PassthroughSubject<Int, TestError>, TestError>()
                let pub = subject.switchToLatest()
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                pub.subscribe(sub)
                
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
                
                expect(sub.events).to(equal([.completion(.failure(.e0))]))
            }
            
            // MARK: 1.4 should relay finish when there are no unfinished children
            it("should relay finish when there are no unfinished children") {
                let subject1 = PassthroughSubject<Int, TestError>()
                let subject2 = PassthroughSubject<Int, TestError>()
                
                let subject = PassthroughSubject<PassthroughSubject<Int, TestError>, TestError>()
                let pub = subject.switchToLatest()
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                pub.subscribe(sub)
                
                subject.send(subject1)
                subject1.send(completion: .finished)
                expect(sub.events).to(equal([]))
                
                subject.send(subject2)
                
                subject2.send(completion: .finished)
                expect(sub.events).to(equal([]))
                
                subject.send(completion: .finished)
                expect(sub.events).to(equal([.completion(.finished)]))
            }

            #if !USE_COMBINE
            // MARK: 1.5 should finish when the last child finish
            it("should finish when the last child finish") {
                let subject1 = PassthroughSubject<Int, TestError>()
                let subject2 = PassthroughSubject<Int, TestError>()
                
                let subject = PassthroughSubject<PassthroughSubject<Int, TestError>, TestError>()
                let pub = subject.switchToLatest()
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                pub.subscribe(sub)
                
                subject.send(subject1)
                subject1.send(completion: .finished)
                expect(sub.events).to(equal([]))
                
                subject.send(subject2)
                expect(sub.events).to(equal([]))
                
                subject.send(completion: .finished)
                expect(sub.events).to(equal([]))
                
                // FIXME: Combine can't pass this, won't get any event. Is it a feature or bug? 🤔
                subject2.send(completion: .finished)
                expect(sub.events).to(equal([.completion(.finished)]))
            }
            #endif
            
            #if !USE_COMBINE
            // MARK: 1.6 should send as many values as demand
            it("should send as many values as demand") {
                let subject1 = PassthroughSubject<Int, Never>()
                let subject2 = PassthroughSubject<Int, Never>()
                
                let subject = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
                
                let pub = subject.switchToLatest()
                let sub = TestSubscriber<Int, Never>(receiveSubscription: { (s) in
                    s.request(.max(10))
                }, receiveValue: { v in
                    return [0, 10].contains(v) ? .max(1) : .none
                }, receiveCompletion: { c in
                })
                pub.subscribe(sub)
                
                subject.send(subject1)
                
                10.times { subject1.send($0) }
                
                subject.send(subject2)
                
                (10..<20).forEach { subject2.send($0) }
                
                // FIXME: Combine can't pass this, will get "[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]". Is it a feature or bug? 🤔
                let expected = (0..<12).map { TestSubscriberEvent<Int, Never>.value($0) }
                expect(sub.events).to(equal(expected))
            }
            #endif
        }
        
        // MARK: - Demands
        describe("Demands") {
            
            // MARK: 2.1 should always request .unlimited when subscribing
            it("should always request .unlimited when subscribing") {
                let pub = TestSubject<Just<Int>, Never>()
                
                let sub = makeTestSubscriber(Int.self, Never.self, .max(10))
                pub.switchToLatest().subscribe(sub)
                
                pub.send(Just(1))
                pub.send(Just(1))
                
                expect(pub.subscription.requestDemandRecords).to(equal([.unlimited]))
                expect(pub.subscription.syncDemandRecords).to(equal([.max(0), .max(0)]))
            }
        }
    }
}
