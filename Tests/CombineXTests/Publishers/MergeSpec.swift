import CXShim
import CXTestUtility
import Nimble
import Quick

class MergeSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: It should merge 8 upstreams
            it("should merge 8 upstreams") {
                let subjects = Array.make(count: 8, make: PassthroughSubject<Int, TestError>())
                let merge = Publishers.Merge8(
                    subjects[0], subjects[1], subjects[2], subjects[3],
                    subjects[4], subjects[5], subjects[6], subjects[7]
                    )

                let sub = TracingSubscriber<Int, TestError>(receiveSubscription: { s in
                    s.request(.unlimited)
                }, receiveValue: { _ in
                    return .none
                }, receiveCompletion: { _ in
                })

                merge.subscribe(sub)
                
                100.times {
                    subjects.randomElement()!.send($0)
                }

                let events = (0..<100).map {
                    TracingSubscriberEvent<Int, TestError>.value($0)
                }
                expect(sub.events) == events
            }
            
            // MARK: It should merge many upstreams
            it("should merge many upstreams") {
                let subjects = Array.make(count: 9, make: PassthroughSubject<Int, TestError>())

                let merge = Publishers.MergeMany(subjects)
                let sub = TracingSubscriber<Int, TestError>(receiveSubscription: { s in
                    s.request(.unlimited)
                }, receiveValue: { _ in
                    return .none
                }, receiveCompletion: { _ in
                })

                merge.subscribe(sub)
                
                100.times {
                    subjects.randomElement()!.send($0)
                }

                let events = (0..<100).map {
                    TracingSubscriberEvent<Int, TestError>.value($0)
                }
                expect(sub.events) == events
            }
        }
    }
}
