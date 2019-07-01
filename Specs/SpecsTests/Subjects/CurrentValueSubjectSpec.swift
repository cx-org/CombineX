import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class CurrentValueSubjectSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Send Values
        describe("Send Values") {
            
            // MARK: * should send value when subscribe
            it("should send value when subscribe") {
                let subject = CurrentValueSubject<Int, CustomError>(1)
                
                let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                    s.request(.max(1))
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { s in
                })
                
                subject.subscribe(sub)
                
                expect(sub.events).to(equal([.value(1)]))
            }
            
            // MARK: * should not send values after error
            it("should not send values after error") {
                let subject = CurrentValueSubject<Int, CustomError>(1)
                
                let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                    s.request(.unlimited)
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { s in
                })
                
                subject.subscribe(sub)
                
                subject.send(completion: .failure(.e0))
                
                subject.send(1)
                subject.send(1)
                subject.send(1)
                
                expect(sub.events).to(equal([.value(1), .completion(.finished)]))
            }
        }
    }
}
