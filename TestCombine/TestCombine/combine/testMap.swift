//
//  testMap.swift
//  TestCombine
//
//  Created by Quentin MED on 2019/6/14.
//  Copyright © 2019 Quentin Jin. All rights reserved.
//

import Foundation
#if CombineQ
import CombineQ
#else
import Combine
#endif

func testMap() {
    
    let pub = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3, 4, 5])
        .map { $0 * $0 }
    
    let sub = AnySubscriber<Int, Never>(receiveSubscription: { (s) in
        
        debugPrint(s, type(of: s))
        
        print("[AnySub] receive subscription", s)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//            print("[AnySub] try to cancel subscription")
//            subscription?.cancel()
//            print("[AnySub] subscription is canceld")
//
            print("[AnySub] request again")
            s.request(.max(1))
        }
        s.request(.max(1))
        
//        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//            print("[AnySub] request more ")
//            s.request(.max(1))
//        }
    }, receiveValue: { i in
        print("[AnySub] receive value", i, CFAbsoluteTimeGetCurrent())
        
        //        print("[AnySub] cancel subscription when receive value", subscription as Any)
        //        subscription?.cancel()
        Thread.sleep(forTimeInterval: 1.5)
        return .max(1)
    }, receiveCompletion: {
        print("[AnySub] receive completion", $0)
    })
    
    pub.subscribe(sub)
    
}

/*
 [AnySub] receive value 1
 [AnySub] receive value 1
 [AnySub] receive value 4
 [AnySub] receive value 4
 [AnySub] receive value 9
 [AnySub] receive value 9
 [AnySub] receive value 16
 [AnySub] receive value 16
 [AnySub] receive value 25
 [AnySub] receive value 25
 [AnySub] receive completion finished
 */
