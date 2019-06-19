import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class AssignSpec: QuickSpec {
    
    override func spec() {
        
        it("should bind value for key path when receive value and stop when complete") {
            let subject = PassthroughSubject<Int, Never>()
            
            class Obj {
                var i = 1
            }
            
            let obj = Obj()
            let cancellable = subject.assign(to: \Obj.i, on: obj)
            
            subject.send(2)
            
            expect(obj.i).to(equal(2))
            
            subject.send(completion: .finished)
            subject.send(3)
            
            expect(obj.i).to(equal(2))
            
            _ = cancellable
        }
        
        it("should release root when complete") {
            let subject = PassthroughSubject<Int, Never>()
            
            class Obj {
                var i = 1
            }
            
            var cancel: AnyCancellable?
            weak var obj: Obj?
            do {
                let o = Obj()
                cancel = subject.assign(to: \Obj.i, on: o)
                obj = o
            }
            
            expect(obj).toNot(beNil())
            subject.send(completion: .finished)
            expect(obj).to(beNil())
            
            _ = cancel
            
        }
        
        it("should release root when cancel") {
            let subject = PassthroughSubject<Int, Never>()
            
            class Obj {
                var i = 1
            }
            
            var cancel: AnyCancellable?
            weak var obj: Obj?
            do {
                let o = Obj()
                cancel = subject.assign(to: \Obj.i, on: o)
                obj = o
            }
            
            expect(obj).toNot(beNil())
            cancel?.cancel()
            expect(obj).to(beNil())
            
            _ = cancel
            
        }
    }
}
