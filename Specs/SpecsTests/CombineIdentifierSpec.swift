import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class CombineIdentifierSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: It should be different to each other
        it("should be different to each other") {
            var set = Set<CombineIdentifier>()
            
            for _ in 0..<1000 {
                set.insert(CombineIdentifier())
            }
            
            expect(set.count).to(equal(1000))
        }
        
        // MARK: It should use object's address as underlying id
        it("should use object's address as underlying id") {
            let obj = CustomObject()
            
            let id1 = CombineIdentifier(obj)
            let id2 = CombineIdentifier(obj)
            
            expect(id1).to(equal(id2))
        }
    }
}
