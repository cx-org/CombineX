import Dispatch
import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class CombineIdentifierSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Unique
        describe("Unique") {
            
            // MARK: 1.1 should be unique to each other
            it("should be unique to each other") {
                let set = Atom<Set<CombineIdentifier>>([])
                let g = DispatchGroup()
                for _ in 0..<100 {
                    let id = CombineIdentifier()
                    DispatchQueue.global().async(group: g) {
                        _ = set.withLockMutating { $0.insert(id) }
                    }
                }
                g.wait()
                
                expect(set.get().count).to(equal(100))
            }
            
            // MARK: 1.2 should use object's address as id
            it("should use object's address as id") {
                let obj = CustomObject()
                
                let id1 = CombineIdentifier(obj)
                let id2 = CombineIdentifier(obj)
                
                expect(id1).to(equal(id2))
            }
        }
    }
}
