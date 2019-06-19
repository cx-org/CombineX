import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class CombineIdentifierSpec: QuickSpec {
    
    override func spec() {
        
        it("should be different") {
            var set = Set<CombineIdentifier>()
            
            for _ in 0..<1000 {
                set.insert(CombineIdentifier())
            }
            
            expect(set.count).to(equal(1000))
        }
        
        it("should use object's address as underlying id") {
            let obj = CustomObject()
            
            let id1 = CombineIdentifier(obj)
            let id2 = CombineIdentifier(obj)
            
            expect(id1).to(equal(id2))
        }
    }
}
