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

    let pub = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3])
    
    var subscription: Subscription?
    let sub = AnySubscriber<Int, Never>(receiveSubscription: { (s) in
        subscription = s
        
        debugPrint(s, type(of: s))
        
        print("[AnySub] receive subscription", s)
        
//        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//            print("[AnySub] try to cancel subscription")
//            subscription?.cancel()
//            print("[AnySub] subscription is canceld")
//        }
        s.request(.max(1))
        
//        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//            print("[AnySub] request more ")
//            s.request(.max(2))
//        }
    }, receiveValue: { i in
        print("[AnySub] receive value", i)
        
//        print("[AnySub] cancel subscription when receive value", subscription as Any)
//        subscription?.cancel()
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
 */
