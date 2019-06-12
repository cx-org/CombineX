//
//  ex.swift
//  TestCombine
//
//  Created by Quentin Jin on 2019/6/12.
//  Copyright © 2019 Quentin Jin. All rights reserved.
//

import Foundation

extension DispatchQueue {
    
    static func isOn(_ queue: DispatchQueue) -> Bool {
        let key = DispatchSpecificKey<()>()
        
        queue.setSpecific(key: key, value: ())
        defer { queue.setSpecific(key: key, value: nil) }
        
        return DispatchQueue.getSpecific(key: key) != nil
    }
}

extension Int {
    
    public static func seconds(_ s: Int) -> Int {
        return s * Int(NSEC_PER_SEC)
    }
    
    public static func seconds(_ s: Double) -> Int {
        return Int(s) * Int(NSEC_PER_SEC)
    }
    
    public static func milliseconds(_ ms: Int) -> Int {
        return ms * Int(NSEC_PER_MSEC)
    }
    
    public static func microseconds(_ us: Int) -> Int {
        return us * Int(NSEC_PER_USEC)
    }
    
    public static func nanoseconds(_ ns: Int) -> Int {
        return ns
    }
}
