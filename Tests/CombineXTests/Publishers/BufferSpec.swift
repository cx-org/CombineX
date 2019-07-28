import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class BufferSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay-ByRequest
        describe("Relay-ByRequest") {
            
            // MARK: 1.1 should request unlimit at beginning if strategy is by request
            it("should request unlimit at beginning if strategy is by request") {
                let subject = TestSubject<Int, TestError>()
                let pub = subject.buffer(size: 5, prefetch: .byRequest, whenFull: .dropOldest)
                
                let sub = TestSubscriber<Int, TestError>(receiveSubscription: { (s) in
                    s.request(.max(2))
                }, receiveValue: { v in
                    return [5].contains(v) ? .max(5) : .max(0)
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                100.times {
                    subject.send($0)
                }
                
                sub.subscription?.request(.max(2))
                
                expect(subject.subscription.requestDemandRecords).to(equal([.unlimited, .max(2), .max(2)]))
                expect(subject.subscription.syncDemandRecords).to(equal(Array(repeating: .max(0), count: 100)))
            }
            
            // MARK: 1.2 should drop oldest
            it("should drop oldest") {
                let subject = PassthroughSubject<Int, TestError>()
                let pub = subject.buffer(size: 5, prefetch: .byRequest, whenFull: .dropOldest)
                let sub = makeTestSubscriber(Int.self, TestError.self, .max(5))
                pub.subscribe(sub)
                
                11.times {
                    subject.send($0)
                }
                
                sub.subscription?.request(.max(5))
                
                let expected = (Array(0..<5) + Array(6..<11)).map { TestEvent<Int, TestError>.value($0) }
                expect(sub.events).to(equal(expected))
            }
            
            // MARK: 1.3 should drop newest
            it("should drop newest") {
                let subject = PassthroughSubject<Int, TestError>()
                let pub = subject.buffer(size: 5, prefetch: .byRequest, whenFull: .dropNewest)
                let sub = makeTestSubscriber(Int.self, TestError.self, .max(5))
                pub.subscribe(sub)
                
                11.times {
                    subject.send($0)
                }
                
                sub.subscription?.request(.max(5))
                
                let expected = Array(0..<10).map { TestEvent<Int, TestError>.value($0) }
                expect(sub.events).to(equal(expected))
            }
            
            // MARK: 1.4 should throw an error
            xit("should drop newest") {
                let subject = PassthroughSubject<Int, TestError>()
                let pub = subject.buffer(size: 5, prefetch: .byRequest, whenFull: .customError({ TestError.e1 }))
                let sub = makeTestSubscriber(Int.self, TestError.self, .max(5))
                pub.subscribe(sub)
                
                100.times {
                    subject.send($0)
                }
                
                // FIXME: Apple's combine doesn't receive error.
                let valueEvents = Array(0..<5).map { TestEvent<Int, TestError>.value($0) }
                let expected = valueEvents + [.completion(.failure(.e1))]
                expect(sub.events).to(equal(expected))
            }
        }
         
        // MARK: - Realy-KeepFull
        describe("KeepFull") {
            
            // MARK: 1.1 should request buffer count at beginning if strategy is keep full
            it("should request buffer count at beginning if strategy is keep full") {
                let subject = TestSubject<Int, TestError>()
                subject.isLogEnabled = true
                let pub = subject.buffer(size: 10, prefetch: .keepFull, whenFull: .dropOldest)
                
                let sub = TestSubscriber<Int, TestError>(receiveSubscription: { (s) in
                    s.request(.max(5))
                }, receiveValue: { v in
                    return [5, 10].contains(v) ? .max(5) : .max(0)
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                100.times {
                    subject.send($0)
                }
                
                sub.subscription?.request(.max(9))
                sub.subscription?.request(.max(5))
                
                expect(subject.subscription.requestDemandRecords).to(equal([.max(10), .max(5), .max(19), .max(5)]))
                
                let max1 = Array(repeating: Demand.max(1), count: 5)
                let max0 = Array(repeating: Demand.max(0), count: 15)
                expect(subject.subscription.syncDemandRecords).to(equal(max1 + max0))
            }
        }
    }
}
