import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class MergeSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: It should merge 8 upstreams
            it("should merge 8 upstreams") {
                let subjects = Array.make(count: 8, make: PassthroughSubject<Int, CustomError>())
                let merge = Publishers.Merge8(
                    subjects[0], subjects[1], subjects[2], subjects[3],
                    subjects[4], subjects[5], subjects[6], subjects[7]
                    )

                let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { s in
                    s.request(.unlimited)
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })

                merge.subscribe(sub)
                
                100.times {
                    subjects.randomElement()!.send($0)
                }

                let events = (0..<100).map {
                    CustomEvent<Int, CustomError>.value($0)
                }
                expect(sub.events).to(equal(events))
            }
            
            
            // MARK: It should merge many upstreams
            it("should merge many upstreams") {
                let subjects = Array.make(count: 9, make: PassthroughSubject<Int, CustomError>())

                let merge = Publishers.MergeMany(subjects)
                let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { s in
                    s.request(.unlimited)
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })

                merge.subscribe(sub)
                
                100.times {
                    subjects.randomElement()!.send($0)
                }

                let events = (0..<100).map {
                    CustomEvent<Int, CustomError>.value($0)
                }
                expect(sub.events).to(equal(events))
            }
        }
    }
}
