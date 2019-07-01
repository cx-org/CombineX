class CustomObject {
    
    var runBody: (() -> Void)?
    var deinitBody: (() -> Void)?
    
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
