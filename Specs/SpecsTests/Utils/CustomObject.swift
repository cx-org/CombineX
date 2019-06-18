class CustomObject {
    
    var fnBody: (() -> Void)?
    var deinitBody: (() -> Void)?
    
    init(fn: (() -> Void)? = nil, deinit: (() -> Void)? = nil) {
        self.fnBody = fn
        self.deinitBody = `deinit`
    }
    
    func fn() {
        self.fnBody?()
    }
    
    deinit {
        self.deinitBody?()
    }
}
