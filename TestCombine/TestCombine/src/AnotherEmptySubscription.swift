//
//  AnotherEmptySubscription.swift
//  TestCombine
//
//  Created by Quentin MED on 2019/6/12.
//  Copyright © 2019 Quentin Jin. All rights reserved.
//

import Foundation
import Combine

private class IdGen {
    static var current = 0
    static let lock = NSLock()
    
    static func next() -> Int {
        lock.lock()
        defer {
            current += 1
            lock.unlock()
        }
        
        return current
    }
}

class AnotherEmptySubscription: Subscription {
    
    let id = IdGen.next()
    
    func request(_ demand: Subscribers.Demand) {
        print("[AES]", id, "got sub's demand", demand)
    }
    
    func cancel() {
        print("[AES]", id, "sub wants to cancel")
    }

    deinit {
        print("[AES]", id, "deinit")
    }
}
