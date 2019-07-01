import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class AnyCancellableSpec: QuickSpec {
    
    override func spec() {
        
        it("should release closure after cancelled") {
            var cancel: Cancellable?
            weak var object: CustomObject?
            
            do {
                let obj = CustomObject()
                
                cancel = AnyCancellable {
                    obj.run()
                }
                
                object = obj
            }
            
            expect(object).toNot(beNil())
            
            cancel?.cancel()
            
            expect(object).to(beNil())
        }
     
        it("should cancel after deinit") {
            var count = 0
            
            do {
                _ = AnyCancellable {
                    count += 1
                }
            }
            
            expect(count).to(equal(1))
        }
    }
}
