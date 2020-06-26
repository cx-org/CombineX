import CXShim
import CXTestUtility
import CXUtility
import Foundation
import Nimble
import Quick

class FailingSubjectSpec: QuickSpec {

    override func spec() {
        
        describe("Subject should not invoke receiveValue on multiple threads at the same time") {
            
            it("PassthroughSubject") {
                let iteration = 100
                let subject = PassthroughSubject<Int, Never>()
                let semaphore = DispatchSemaphore(value: 0)
                
                let count = LockedAtomic<Int>(0)
                var collision = false
                let c = subject.sink { _ in
                    if count.isMutating {
                        // Check to see if this closure is concurrently invoked
                        collision = true
                    }
                    count.withLockMutating { count in
                        // Make sure we're in the handler for enough time to get a concurrent invocation
                        Thread.sleep(forTimeInterval: 0.001)
                        count += 1
                        if count == iteration {
                            semaphore.signal()
                        }
                    }
                }
                
                // Try to send from a hundred different threads at once
                DispatchQueue.global().concurrentPerform(iterations: iteration) { _ in
                    subject.send(1)
                }
                
                semaphore.wait()
                c.cancel()
                expect(count.load()) == iteration
                
                // FIXME: collision should not happen
                expect(collision).toFail(beFalse())
            }
            
            it("CurrentValueSubject") {
                let iteration = 100
                let subject = CurrentValueSubject<Int, Never>(0)
                let semaphore = DispatchSemaphore(value: 0)
                
                let count = LockedAtomic<Int>(0)
                var collision = false
                let c = subject.sink { _ in
                    if count.isMutating {
                        // Check to see if this closure is concurrently invoked
                        collision = true
                    }
                    count.withLockMutating { count in
                        // Make sure we're in the handler for enough time to get a concurrent invocation
                        Thread.sleep(forTimeInterval: 0.001)
                        count += 1
                        if count == iteration {
                            semaphore.signal()
                        }
                    }
                }
                
                // Try to send from a hundred different threads at once
                DispatchQueue.global().concurrentPerform(iterations: iteration - 1) { _ in
                    subject.send(1)
                }
                
                semaphore.wait()
                c.cancel()
                expect(count.load()) == iteration
                
                // FIXME: collision should not happen
                expect(collision).toFail(beFalse())
            }
        }
    }
}
