import CXShim
import CXTestUtility
import CXUtility
import Foundation
import Nimble
import Quick

class FailingSubjectSpec: QuickSpec {

    override func spec() {
    
        afterEach {
            TestResources.release()
        }
        
        describe("Subject should not invoke receiveValue on multiple threads at the same time") {
            
            it("PassthroughSubject") {
                let sequenceLength = 100
                let subject = PassthroughSubject<Int, Never>()
                let semaphore = DispatchSemaphore(value: 0)
                
                let total = Atom<Int>(val: 0)
                var collision = false
                let c = subject
                   .sink(receiveValue: { value in
                    if total.isMutating {
                         // Check to see if this closure is concurrently invoked
                         collision = true
                      }
                    total.withLockMutating { total in
                         // Make sure we're in the handler for enough time to get a concurrent invocation
                         Thread.sleep(forTimeInterval: 0.001)
                         total += value
                         if total == sequenceLength {
                            semaphore.signal()
                         }
                    }
                   })
                
                // Try to send from a hundred different threads at once
                for _ in 1...sequenceLength {
                   DispatchQueue.global().async {
                      subject.send(1)
                   }
                }
                
                semaphore.wait()
                c.cancel()
                expect(total.get()) == sequenceLength
                
                // FIXME: collision should not happen
                expect(collision).toFail(beFalse())
            }
            
            it("CurrentValueSubject") {
                let sequenceLength = 100
                let subject = CurrentValueSubject<Int, Never>(0)
                let semaphore = DispatchSemaphore(value: 0)
                
                let total = Atom<Int>(val: 0)
                var collision = false
                let c = subject
                   .sink(receiveValue: { value in
                    if total.isMutating {
                         // Check to see if this closure is concurrently invoked
                         collision = true
                      }
                    total.withLockMutating { total in
                         // Make sure we're in the handler for enough time to get a concurrent invocation
                         Thread.sleep(forTimeInterval: 0.001)
                         total += value
                         if total == sequenceLength {
                            semaphore.signal()
                         }
                    }
                   })
                
                // Try to send from a hundred different threads at once
                for _ in 1...sequenceLength {
                   DispatchQueue.global().async {
                      subject.send(1)
                   }
                }
                
                semaphore.wait()
                c.cancel()
                expect(total.get()) == sequenceLength
                
                // FIXME: collision should not happen
                expect(collision).toFail(beFalse())
            }
        }
    }
}
