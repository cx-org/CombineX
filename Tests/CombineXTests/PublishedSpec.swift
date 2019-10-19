import CXShim
import Quick
import Nimble

class PublishedSpec: QuickSpec {
    
    #if swift(>=5.1)
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Publish
        describe("Publish") {
            
            // MARK: 1.1 should publish value's change
            it("Publish") {
                class X {
                    @Published var name = 0
                }
                let x = X()
                let sub = makeTestSubscriber(Int.self, Never.self, .unlimited)
                x.$name.subscribe(sub)

                expect(sub.events).to(equal([.value(0)]))
                
                x.name = 1
                x.name = 2
                
                expect(sub.events).to(equal([.value(0), .value(1), .value(2)]))
            }
        }
        
        // MARK: - Demand
        describe("Demand") {
            
            // MARK: 2.1 should send as many values as demand
            it("should send as many values as demand") {
                class X {
                    @Published var name = 0
                }
                let x = X()
                let sub = TestSubscriber<Int, Never>(receiveSubscription: { s in
                    s.request(.max(10))
                }, receiveValue: { v in
                    return [0, 10].contains(v) ? .max(1) : .max(0)
                }, receiveCompletion: { c in
                })
                
                x.$name.subscribe(sub)

                100.times {
                    x.name = $0
                }
                
                expect(sub.events.count).to(equal(13))
            }
        }
    }
    #endif
}
