import PlaygroundSupport
import Foundation
import Combine

enum CustomError: Error {
    case e1
}

PlaygroundPage.current.needsIndefiniteExecution = true

private var deinit_observer_key: Void = ()

class DeinitObserver {
    
    private var body: (() -> Void)?
    
    private init(_ body: @escaping () -> Void) {
        self.body = body
    }
    
    @discardableResult
    static func observe(_ observable: AnyObject, whenDeinit body: @escaping () -> Void) -> DeinitObserver {
        let observer = DeinitObserver(body)
        objc_setAssociatedObject(observable, &deinit_observer_key, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return observer
    }
    
    deinit {
        self.body?()
    }
}

var count = 0
let g = DispatchGroup()
let q = DispatchQueue(label: UUID().uuidString)

let subject = PassthroughSubject<Int, Never>()
let subscriber = AnySubscriber<Int, Never>(receiveSubscription: { (s) in
    s.request(.unlimited)
}, receiveValue: { v in
    q.sync {
        count += 1
    }
    print("receive value", v)
    return .none
}, receiveCompletion: { c in
    print("receive completion", c)
})
subject.prefix(5).subscribe(subscriber)

for i in 0..<1000 {
    DispatchQueue.global().async(group: g) {
        subject.send(i)
    }
}

g.wait()

print("receive", count)




