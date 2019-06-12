//
//  testJust.swift
//  TestCombine
//
//  Created by Quentin Jin on 2019/6/12.
//  Copyright © 2019 Quentin Jin. All rights reserved.
//

import Foundation
#if CombineQ
import CombineQ
#else
import Combine
#endif

func testJust() {
    let sema = DispatchSemaphore(value: 0)
    
    let pub = Publishers.Just(1)
    
    var subscription: Subscription?
    let sub = AnySubscriber<Int, Never>(receiveSubscription: { (s) in
        subscription = s
        
        print("[AnySub] receive subscription", s)
        
//        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//            print("[AnySub] try to cancel subscription")
//            subscription?.cancel()
//            print("[AnySub] subscription is canceld")
//        }
        
        s.request(.unlimited)
    }, receiveValue: { i in
        print("[AnySub] receive value", i)
        Thread.sleep(forTimeInterval: 5)
        
//        subscription?.cancel()
        
        DispatchQueue.main.async {
            print("async")
        }
        return .max(0)
    }, receiveCompletion: {
        print("[AnySub] receive completion", $0)
    })
    
    pub.subscribe(on: DispatchQueueScheduler(.main))
        .subscribe(sub)
}
