//
//  testEmpty.swift
//  TestCombine
//
//  Created by Quentin MED on 2019/6/13.
//  Copyright © 2019 Quentin Jin. All rights reserved.
//

import Foundation
#if CombineQ
import CombineQ
#else
import Combine
#endif

func testEmpty() {
    let pub = Publishers.Empty(completeImmediately: true, outputType: Int.self, failureType: Never.self)
    
    var subscription: Subscription?
    let sub = AnySubscriber<Int, Never>(receiveSubscription: { (s) in
        subscription = s
        
        print(type(of: s))
        debugPrint(s)
        for m in Mirror(reflecting: s).children {
            print(m.label, m.value)
        }
        
        print("[AnySub] receive subscription", s)
        
        //        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
        //            print("[AnySub] try to cancel subscription")
        //            subscription?.cancel()
        //            print("[AnySub] subscription is canceld")
        //        }
        s.request(.max(-1))
    }, receiveValue: { i in
        print("[AnySub] receive value", i)
        
        print("[AnySub] cancel subscription when receive value", subscription)
        subscription?.cancel()
        return .max(0)
    }, receiveCompletion: {
        print("[AnySub] receive completion", $0)
    })
    
    pub.subscribe(sub)
}


/*
 [AnySub] receive subscription Just
 [AnySub] receive value 1
 [AnySub] cancel subscription when receive value Optional(Just)
 [AnySub] receive completion finished
 */
