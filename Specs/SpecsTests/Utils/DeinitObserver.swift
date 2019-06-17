import Foundation

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

private var deinitObserverKey: Void = ()

class DeinitObserver {
    
    private var body: (() -> Void)?
    
    private init(_ body: @escaping () -> Void) {
        self.body = body
    }
    
    @discardableResult
    static func observe(_ observable: AnyObject, whenDeinit body: @escaping () -> Void) -> DeinitObserver {
        let observer = DeinitObserver(body)
        objc_setAssociatedObject(observable, &deinitObserverKey, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return observer
    }
    
    deinit {
        self.body?()
    }
}

#endif
