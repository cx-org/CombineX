import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class AnyCancellableSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            Resources.release()
        }
        
        // MARK: - Cancel
        describe("Cancel") {
            
            // MARK: 1.1 should cancel self when cancel is called
            it("should cancel self when cancel is called") {
                var count = 0
                
                let cancel = AnyCancellable {
                    count += 1
                }
                
                cancel.cancel()
                
                expect(count).to(equal(1))
            }
            
            // MARK: 1.2 should cancel parent when cancel is called
            it("should cancel parent when cancel is called") {
                var count = 0
                
                let parent = AnyCancellable {
                    count += 1
                }
                
                let cancel = AnyCancellable(parent)
                
                cancel.cancel()
                
                expect(count).to(equal(1))
            }
            
            // MARK: 1.3 should cancel when deinit
            it("should cancel when deinit") {
                var count = 0
                
                do {
                    _ = AnyCancellable {
                        count += 1
                    }
                }
                
                expect(count).to(equal(1))
            }
        }
        
        // MARK: - Release Resources
        describe("Release Resources") {
            
            // MARK: 2.1 should release closure after cancelled
            it("should release closure after cancelled") {
                var cancel: Cancellable?
                weak var object: TestObject?
                
                do {
                    let obj = TestObject()
                    
                    cancel = AnyCancellable {
                        obj.run()
                    }
                    
                    object = obj
                }
                
                expect(object).toNot(beNil())
                
                cancel?.cancel()
                
                expect(object).to(beNil())
            }
        }
        
        // MARK: - Hash
        describe("Hash") {
            
            // MARK: 3.1 should use ObjectIdentifier to implement hash
            it("should use ObjectIdentifier to implement hash") {
                let cancel = AnyCancellable { }
                let id = ObjectIdentifier(cancel)
                expect(cancel.hashValue).to(equal(id.hashValue))
            }
            
            // MARK: 3.2
            it("should use ObjectIdentifier to implement equal") {
                let lhs = AnyCancellable { }
                let rhs = AnyCancellable { }
                expect(lhs).to(equal(lhs))
                expect(lhs).toNot(equal(rhs))
            }
        }
        
        // MARK: - Collection
        describe("Collection") {
            
            it("should be stored in array") {
                var cancels: [AnyCancellable] = []
                let cancel = AnyCancellable { }
                
                cancel.store(in: &cancels)
                cancel.store(in: &cancels)
                cancel.store(in: &cancels)
                
                expect(cancels).to(equal([cancel, cancel, cancel]))
            }
            
            it("should be stored in set") {
                var cancels: Set<AnyCancellable> = []
                let cancel = AnyCancellable { }
                
                cancel.store(in: &cancels)
                cancel.store(in: &cancels)
                cancel.store(in: &cancels)
                
                expect(cancels).to(equal([cancel]))
            }
        }
    }
}
