import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class MeasureIntervalSpec: QuickSpec {
    
    override func spec() {
    
        // MARK: Measure Interval
        describe("Measure Interval") {
            
            // MARK: 1.1 should measure interval as expected
            it("should measure interval as expected") {
                let subject = PassthroughSubject<Int, Never>()
                
                let pub = subject.measureInterval(using: DispatchQueue.main.cx)
                var t = Date()
                var dts: [TimeInterval] = []
                let sub = TracingSubscriber<CXWrappers.DispatchQueue.SchedulerTimeType.Stride, Never>(receiveSubscription: { s in
                    s.request(.unlimited)
                    t = Date()
                }, receiveValue: { _ in
                    dts.append(-t.timeIntervalSinceNow)
                    t = Date()
                    return .none
                })
                
                pub.subscribe(sub)
                
                Thread.sleep(forTimeInterval: 0.2)
                subject.send(1)
                
                Thread.sleep(forTimeInterval: 0.1)
                subject.send(1)
                
                subject.send(completion: .finished)
                
                expect(sub.eventsWithoutSubscription).to(haveCount(dts.count + 1))
                expect(sub.eventsWithoutSubscription.last) == .completion(.finished)
                for (event, dt) in zip(sub.eventsWithoutSubscription.dropLast(), dts) {
                    expect(event.value?.seconds).to(beCloseTo(dt, within: 0.1))
                }
            }
        }
    }
}
