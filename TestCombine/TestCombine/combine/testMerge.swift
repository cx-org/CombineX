//
//  testMerge.swift
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


func testMerge() {
    
    let pub1 = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3, 4, 5])
    let pub2 = Publishers.Sequence<[Int], Never>(sequence: [-1, -2, -3, -4, -5])
    
    let sub = AnySubscriber<Int, Never>(receiveSubscription: { (s) in
        
        debugPrint(s, type(of: s))
        
        print("[AnySub] receive subscription", s)
        
        s.request(.unlimited)
        
//        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//            print("[AnySub] request more ")
//            s.request(.max(1))
//        }
    }, receiveValue: { i in
        print("[AnySub] receive value", i, Thread.current)
        
//        print("[AnySub] cancel subscription when receive value", subscription as Any)
//        subscription?.cancel()
//        Thread.sleep(forTimeInterval: 1.5)
        return .max(1)
    }, receiveCompletion: {
        print("[AnySub] receive completion", $0)
    })
    
    let pub = pub1.merge(with: pub2)
    pub.subscribe(sub)
}
