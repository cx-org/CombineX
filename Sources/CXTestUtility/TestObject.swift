public class TestObject {
    
    let runBody: (() -> Void)?
    let deinitBody: (() -> Void)?
    
    public init(run: (() -> Void)? = nil, deinit: (() -> Void)? = nil) {
        self.runBody = run
        self.deinitBody = `deinit`
    }
    
    public func run() {
        self.runBody?()
    }
    
    deinit {
        self.deinitBody?()
    }
}
