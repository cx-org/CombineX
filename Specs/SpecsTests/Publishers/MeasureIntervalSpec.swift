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
        
        it("should measure interval as expected") {
            let subject = PassthroughSubject<Int, Never>()
            
            let pub = subject.measureInterval(using: CustomScheduler.main)
            let sub = CustomSubscriber<CustomScheduler.SchedulerTimeType.Stride, Never>(receiveSubscription: { (s) in
                s.request(.unlimited)
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
            
            pub.subscribe(sub)
            
            Thread.sleep(forTimeInterval: 0.3)
            subject.send(1)
            
            Thread.sleep(forTimeInterval: 0.2)
            subject.send(1)
            
            Thread.sleep(forTimeInterval: 0.1)
            subject.send(completion: .finished)
            
            expect(sub.events.count).to(equal(3))
            for (idx, event) in sub.events.enumerated() {
                switch (idx, event) {
                case (0, .value(let s)):
                    expect(s.seconds - 0.3).to(beLessThan(0.01))
                case (1, .value(let s)):
                    expect(s.seconds - 0.2).to(beLessThan(0.01))
                case (2, .completion(.finished)):
                    break
                default:
                    fail()
                }
            }
        }
    }
}
