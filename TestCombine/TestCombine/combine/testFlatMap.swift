//
//  testFlatMap.swift
//  TestCombine
//
//  Created by Quentin Jin on 2019/6/14.
//  Copyright © 2019 Quentin Jin. All rights reserved.
//

import Foundation
#if CombineQ
import CombineQ
#else
import Combine
#endif

func testFlatMap() {

    let pub = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3])
        .flatMap(maxPublishers: .max(2)) { val -> AnyPublisher<Int, Never> in
            print("[FlatMap] one publishers produced")

            let subscription = AnotherSubscription()
            return AnyPublisher<Int, Never> { s in
                DispatchQueue.global().async {
                    s.receive(subscription: subscription)
                    Thread.sleep(forTimeInterval: 1)
                    print("[AnyPub_Pub_\(val)] send")
                    print("[AnyPub_Pub_\(val)] send feedback", s.receive(val))
                    print("[AnyPub_Pub_\(val)] send")
                    print("[AnyPub_Pub_\(val)] send feedback", s.receive(val))
                    print("[AnyPub_Pub_\(val)] send finished")
                    s.receive(completion: .finished)
                }
            }
        }

    let sub = AnySubscriber<Int, Never>(receiveSubscription: { (s) in
        
        print("[AnySub] receive subscription")
        
        //        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
        //            print("[AnySub] try to cancel subscription")
        //            subscription?.cancel()
        //            print("[AnySub] subscription is canceld")
        //        }
        
//        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//            print("[AnySub] request more ")
//            s.request(.max(1))
//        }
        
        s.request(.max(1))
    }, receiveValue: { i in
        print("[AnySub] receive value", i)
        
//        Thread.sleep(forTimeInterval: 1.5)
        return .max(1)
    }, receiveCompletion: {
        print("[AnySub] receive completion", $0)
    })
    
    pub.subscribe(sub)
}

/*
 [AnySub] receive subscription FlatMap
 [FlatMap] one publishers produced
 [FlatMap] one publishers produced
 [AnotherSubscription: 0] deinit
 [AnotherSubscription: 1] request demand max(1)
 [AnotherSubscription: 2] request demand max(1)
 [AnyPub_Pub_1] send
 [AnyPub_Pub_2] send
 [AnySub] receive value 1
 [AnyPub_Pub_2] send feedback max(0)
 [AnyPub_Pub_2] send
 [AnySub] receive value 2
 [AnyPub_Pub_2] send feedback max(1)
 [AnyPub_Pub_2] send finished
 [AnyPub_Pub_1] send feedback max(1)
 [AnyPub_Pub_1] send
 [AnySub] receive value 1
 [AnyPub_Pub_1] send feedback max(1)
 [AnyPub_Pub_1] send finished
 [FlatMap] one publishers produced
 [AnotherSubscription: 2] deinit
 [AnotherSubscription: 1] deinit
 [AnotherSubscription: 3] request demand max(1)
 [AnyPub_Pub_3] send
 [AnySub] receive value 3
 [AnyPub_Pub_3] send feedback max(1)
 [AnyPub_Pub_3] send
 [AnySub] receive value 3
 [AnyPub_Pub_3] send feedback max(1)
 [AnyPub_Pub_3] send finished
 [AnotherSubscription: 3] deinit


 */
