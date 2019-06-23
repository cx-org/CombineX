import Foundation
import CombineX
import PlaygroundSupport

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

let pub = PassthroughSubject<Int, Never>()

do {
    let cancel = pub.sink {
        _ = $0
    }
    
    DeinitObserver.observe(cancel) {
        print("sink deinit")
    }
    
    cancel.cancel()
}

print("combine x")
