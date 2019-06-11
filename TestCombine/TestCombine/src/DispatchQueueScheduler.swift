//
//  DispatchQueueScheduler.swift
//  iOSDemo
//
//  Created by Quentin Jin on 2019/6/12.
//  Copyright © 2019 v2ambition. All rights reserved.
//

import Foundation
import Combine
import Dispatch

class DispatchQueueScheduler: Scheduler {
    
    let queue: DispatchQueue
    
    init(_ queue: DispatchQueue) {
        self.queue = queue
    }
    
    typealias SchedulerTimeType = UInt64
    
    typealias SchedulerOptions = Never
    
    var now: UInt64 {
        return DispatchTime.now().uptimeNanoseconds
    }
    
    var minimumTolerance: UInt64.Stride {
        return 0
    }
    
    func schedule(options: Never?, _ action: @escaping () -> Void) {
        self.queue.async(execute: action)
    }
    
    func schedule(after date: UInt64, tolerance: UInt64.Stride, options: Never?, _ action: @escaping () -> Void) {
        
        self.queue.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: date), execute: action)
    }
    
    func schedule(after date: UInt64, interval: UInt64.Stride, tolerance: UInt64.Stride, options: Never?, _ action: @escaping () -> Void) -> Cancellable {
        
        self.queue.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: date) + .nanoseconds(Int(interval)), execute: action)
        
        return AnyCancellable {
            print("dispatch queue schedueler cancelled")
        }
    }
}

extension Int: SchedulerTimeIntervalConvertible {
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


extension DispatchQueue {
    
    static func isOn(_ queue: DispatchQueue) -> Bool {
        let key = DispatchSpecificKey<()>()
        
        queue.setSpecific(key: key, value: ())
        defer { queue.setSpecific(key: key, value: nil) }
        
        return DispatchQueue.getSpecific(key: key) != nil
    }
}
