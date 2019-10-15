import Foundation

extension Timer {
    
    class func cx_init(timeInterval interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) -> Timer {
        #if canImport(ObjectiveC)
        guard #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) else {
            return Timer(timeInterval: interval, target: self, selector: #selector(cx_fireAction), userInfo: block, repeats: repeats)
        }
        #endif
        return Timer(timeInterval: interval, repeats: repeats, block: block)
    }
    
    class func cx_init(fire date: Date, interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) -> Timer {
        #if canImport(ObjectiveC)
        guard #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) else {
            return Timer(fireAt: date, interval: interval, target: self, selector: #selector(cx_fireAction), userInfo: block, repeats: repeats)
        }
        #endif
        return Timer(fire: date, interval: interval, repeats: repeats, block: block)
    }
    
    @discardableResult class func cx_scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) -> Timer {
        #if canImport(ObjectiveC)
        guard #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) else {
            return self.scheduledTimer(timeInterval: interval, target: self, selector: #selector(cx_fireAction), userInfo: block, repeats: repeats)
        }
        #endif
        return self.scheduledTimer(withTimeInterval: interval, repeats: repeats, block: block)
    }
    
    #if canImport(ObjectiveC)
    
    @objc private class func cx_fireAction(timer: Timer) {
        let block = timer.userInfo as? ((Timer) -> Void)
        block?(timer)
    }
    
    #endif
}

extension RunLoop {
    
    func cx_perform(inModes modes: [RunLoop.Mode], block: @escaping () -> Void) {
        #if canImport(ObjectiveC)
        guard #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) else {
            self.perform(#selector(RunLoop.cx_performAction), target: RunLoop.self, argument: block, order: 0, modes: modes)
            return
        }
        #endif
        self.perform(inModes: modes, block: block)
    }
    
    func cx_perform(_ block: @escaping () -> Void) {
        #if canImport(ObjectiveC)
        guard #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) else {
            self.cx_perform(inModes: [.default], block: block)
            return
        }
        #endif
        self.perform(block)
    }
    
    #if canImport(ObjectiveC)
    
    @objc private class func cx_performAction(argument: Any) {
        let block = argument as? (() -> Void)
        block?()
    }
    
    #endif
}
