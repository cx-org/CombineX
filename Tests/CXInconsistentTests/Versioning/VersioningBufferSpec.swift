import CXShim
import CXTestUtility
import Nimble
import Quick

class VersioningBufferSpec: QuickSpec {
    
    override func spec() {
        
        #if USE_COMBINE // FIXME: MACOS11: out of sync
        it("should request unlimit at beginning if strategy is by request") {
            let subject = TracingSubject<Int, TestError>()
            let pub = subject.buffer(size: 5, prefetch: .byRequest, whenFull: .dropOldest)
            let sub = pub.subscribeTracingSubscriber(initialDemand: .max(2), subsequentDemand: { [5].contains($0) ? .max(5) : .max(0) })
            
            subject.send(contentsOf: 0..<100)
            
            sub.subscription?.request(.max(2))
            
            expect(subject.subscription.requestDemandRecords).toVersioning([
                .v11_0: equal([.unlimited, .max(2), .max(2)]),
                .v12_0: equal([.unlimited]),
            ])
            expect(subject.subscription.syncDemandRecords) == Array(repeating: .max(0), count: 100)
        }
        
        it("should request buffer count at beginning if strategy is keep full") {
            let subject = TracingSubject<Int, TestError>()
            let pub = subject.buffer(size: 10, prefetch: .keepFull, whenFull: .dropOldest)
            let sub = pub.subscribeTracingSubscriber(initialDemand: .max(5), subsequentDemand: { [5, 10].contains($0) ? .max(5) : .max(0) })
            
            subject.send(contentsOf: 0..<100)
            
            sub.subscription?.request(.max(9))
            sub.subscription?.request(.max(5))
            
            expect(subject.subscription.requestDemandRecords).toVersioning([
                .v11_0: equal([.max(10), .max(5), .max(19), .max(5)]),
                .v12_0: equal([.max(10), .max(10)])
            ])
            let max1 = Array(repeating: Subscribers.Demand.max(1), count: 5)
            expect(subject.subscription.syncDemandRecords).toVersioning([
                .v11_0: equal(max1 + Array(repeating: Subscribers.Demand.max(0), count: 15)),
                .v12_0: equal(max1 + Array(repeating: Subscribers.Demand.max(0), count: 10)),
            ])
        }
        #endif
    }
}

