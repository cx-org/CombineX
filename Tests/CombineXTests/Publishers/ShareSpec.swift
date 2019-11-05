import CXShim
import CXTestUtility
import Quick
import Nimble

class ShareSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: Relay
        describe("Relay") {
            
            it("should share the upstream") {
                let subject = PassthroughSubject<Int, TestError>()
                var normalCount = 0
                let normal = subject.map { i -> Int in
                    normalCount += 1
                    return i
                }
                normal.subscribe(makeTestSubscriber(Int.self, TestError.self, .unlimited))
                normal.subscribe(makeTestSubscriber(Int.self, TestError.self, .unlimited))
                
                var shareCount = 0
                let share = subject.map { i -> Int in
                    shareCount += 1
                    return i
                }.share()
                
                share.subscribe(makeTestSubscriber(Int.self, TestError.self, .unlimited))
                share.subscribe(makeTestSubscriber(Int.self, TestError.self, .unlimited))
                
                subject.send(1)
                subject.send(2)
                subject.send(3)
                
                expect(normalCount).to(equal(6))
                expect(shareCount).to(equal(3))
            }
        }
    }
}
