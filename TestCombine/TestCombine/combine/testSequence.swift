//
//  testSequence.swift
//  TestCombine
//
//  Created by Quentin Jin on 2019/6/13.
//  Copyright © 2019 Quentin Jin. All rights reserved.
//

import Foundation
#if CombineQ
import CombineQ
#else
import Combine
#endif

func testSequence() {

    let pub = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3, 4, 5])
    
    let sub = AnySubscriber<Int, Never>(receiveSubscription: { (s) in
        
        debugPrint(s, type(of: s))
        
        print("[AnySub] receive subscription", s)
        
//        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//            print("[AnySub] try to cancel subscription")
//            subscription?.cancel()
//            print("[AnySub] subscription is canceld")
//        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            print("[AnySub] request more ")
            s.request(.max(1))
        }
        
        s.request(.max(1))
    }, receiveValue: { i in
        print("[AnySub] receive value", i, CFAbsoluteTimeGetCurrent(), Thread.current)
        
        Thread.sleep(forTimeInterval: 1.5)
        return .max(1)
    }, receiveCompletion: {
        print("[AnySub] receive completion", $0)
    })
    
    pub.subscribe(sub)
    
}

/*
 [AnySub] receive subscription [1, 2, 3]
 [AnySub] receive value 1
 [AnySub] receive value 2
 [AnySub] receive value 3
 [AnySub] receive completion finished
 
 [AnySub] receive subscription [1, 2, 3, 4, 5]
 [AnySub] receive value 1
 [AnySub] request more
 [AnySub] receive value 2

 [AnySub] receive value 1 582192960.189217 <NSThread: 0x600001969300>{number = 1, name = main}
 [AnySub] request more
 [AnySub] receive value 2 582192961.690672 <NSThread: 0x600001969300>{number = 1, name = main}
 [AnySub] receive value 3 582192963.192004 <NSThread: 0x600001969300>{number = 1, name = main}
 [AnySub] receive value 4 582192964.693115 <NSThread: 0x600001969300>{number = 1, name = main}
 [AnySub] receive value 5 582192966.19335 <NSThread: 0x600001969300>{number = 1, name = main}
 [AnySub] receive completion finished

 */
