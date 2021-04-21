import CXShim
import CXTestUtility
import Nimble
import Quick

class FailingFlatMapSpec: QuickSpec {
    
    override func spec() {
        
        it("should forward unlimited request") {
            let subj1 = TracingSubject<Int, Never>()
            let subj2 = TracingSubject<Int, Never>()
            let pub = [subj1, subj2].cx.publisher.flatMap { $0 }
            let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
            
            expect(subj1.subscription.demandRecords).toBranch(
                combine: equal([.unlimited]),
                cx: equal([.max(1)]))
            expect(subj2.subscription.demandRecords).toBranch(
                combine: equal([.unlimited]),
                cx: equal([.max(1)]))
            
            _ = sub
        }
    }
}
