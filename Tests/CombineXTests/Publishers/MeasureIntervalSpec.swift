import Foundation
import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class MeasureIntervalSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
    
        // MARK: Measure Interval
        describe("Measure Interval") {
            
            // MARK: 1.1 should measure interval as expected
            it("should measure interval as expected") {
                let subject = PassthroughSubject<Int, Never>()
                
                let pub = subject.measureInterval(using: TestDispatchQueueScheduler.main)
                let sub = TestSubscriber<TestDispatchQueueScheduler.SchedulerTimeType.Stride, Never>(receiveSubscription: { (s) in
                    s.request(.unlimited)
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                Thread.sleep(forTimeInterval: 0.2)
                subject.send(1)
                
                Thread.sleep(forTimeInterval: 0.1)
                subject.send(1)
                
                subject.send(completion: .finished)
                
                expect(sub.events.count).to(equal(3))
                for (idx, event) in sub.events.enumerated() {
                    switch (idx, event) {
                    case (0, .value(let s)):
                        expect(s.seconds).to(beCloseTo(0.2, within: 0.01))
                    case (1, .value(let s)):
                        expect(s.seconds).to(beCloseTo(0.1, within: 0.01))
                    case (2, .completion(.finished)):
                        break
                    default:
                        fail()
                    }
                }
            }

        }
    }
}
