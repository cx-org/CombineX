class TestObject {
    
    let runBody: (() -> Void)?
    let deinitBody: (() -> Void)?
    
    init(run: (() -> Void)? = nil, deinit: (() -> Void)? = nil) {
        self.runBody = run
        self.deinitBody = `deinit`
    }
    
    func run() {
        self.runBody?()
    }
    
    deinit {
        self.deinitBody?()
    }
}
