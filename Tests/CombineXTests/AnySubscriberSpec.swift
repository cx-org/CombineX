import CXShim
import CXTestUtility
import Nimble
import Quick

class AnySubscriberSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Erase
        describe("Erase") {
            
            // MARK: 1.1 should preserve combine identifier
            it("should preserve combine identifier") {
                let sub1 = TracingSubscriber<Int, TestError>()
                let sub2 = TracingSubscriber<Int, TestError>()
                
                let erased1 = AnySubscriber(sub1)
                let erased2 = AnySubscriber(sub2)
                
                expect(sub1.combineIdentifier) == erased1.combineIdentifier
                expect(sub2.combineIdentifier) == erased2.combineIdentifier
                expect(sub1.combineIdentifier) != erased2.combineIdentifier
                
                let erased1_2 = AnySubscriber(sub1)
                
                expect(erased1.combineIdentifier) == erased1_2.combineIdentifier
                
                let emptyErased = AnySubscriber<Int, TestError>()
                
                expect(emptyErased.combineIdentifier) == emptyErased.combineIdentifier
            }
            
            // MARK: 1.2 should preserve description
            it("should preserve description and mirror") {
                let emptyErased = AnySubscriber<Int, TestError>()
                
                expect(emptyErased.description) == "Anonymous AnySubscriber"
                expect(emptyErased.playgroundDescription as? String) == "Anonymous AnySubscriber"
                
                let sub = TracingSubscriber<Int, TestError>()
                let erased = AnySubscriber(sub)
                
                expect(sub.description) == erased.description
                
                expect(sub.playgroundDescription as? String) == sub.description
                expect(erased.playgroundDescription as? String) == erased.description
                
                expect(sub.customMirror.description) == erased.customMirror.description
            }
        }
        
        // MARK: - Events
        describe("Events") {
            
            // MARK: 2.1 shoud forward events to underlying subscriber
            it("shoud forward events to underlying subscriber") {
                let pub = PassthroughSubject<Int, TestError>()
                let sub = TracingSubscriber<Int, TestError>(receiveSubscription: { $0.request(.unlimited)})
                let erased = AnySubscriber(sub)
                pub.subscribe(erased)
                
                pub.send(1)
                pub.send(2)
                pub.send(completion: .failure(.e0))
                
                expect(sub.eventsWithoutSubscription) == [.value(1), .value(2), .completion(.failure(.e0))]
            }
        }
    }
}
