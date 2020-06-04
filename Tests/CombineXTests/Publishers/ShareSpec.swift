import CXShim
import CXTestUtility
import Nimble
import Quick

class ShareSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: Relay
        describe("Relay") {
            
            it("should share the upstream") {
                let subject = PassthroughSubject<Int, TestError>()
                var normalCount = 0
                let normal = subject.map { i -> Int in
                    normalCount += 1
                    return i
                }
                _ = normal.subscribeTracingSubscriber(initialDemand: .unlimited)
                _ = normal.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                var shareCount = 0
                let share = subject.map { i -> Int in
                    shareCount += 1
                    return i
                }.share()
                
                _ = share.subscribeTracingSubscriber(initialDemand: .unlimited)
                _ = share.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject.send(1)
                subject.send(2)
                subject.send(3)
                
                expect(normalCount) == 6
                expect(shareCount) == 3
            }
        }
    }
}
