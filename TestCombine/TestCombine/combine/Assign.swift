//
//  Assign.swift
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

func testAssign() {
    let sema = DispatchSemaphore(value: 0)
    
    let pub = AnyPublisher<Int, Never> { (sub) in
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let subcription = AnotherSubscription()
            
            print("[AnyPub] send subscription 0")
            sub.receive(subscription: subcription)
            print("[AnyPub] send 0")
            print("[AnyPub] want more", sub.receive(0))
            
            sub.receive(completion: .finished)
            
            print("[AnyPub] send subscription 1")
            sub.receive(subscription: subcription)
            print("[AnyPub] send 1")
            print("[AnyPub] want more", sub.receive(1))
            
            sub.receive(completion: .finished)
            
            print("[AnyPub] send 2")
            _ = sub.receive(2)
            
            sema.signal()
        }
    }
    
    class Box {
        var age: Int = 0 {
            didSet {
                print("[Box] did set age", age, oldValue)
            }
        }
    }
    
    let box = Box()
    let sub = Subscribers.Assign<Box, Int>(object: box, keyPath: \.age)
    
    print("[Assign] cancel")
    sub.cancel()

    pub.subscribe(sub)
    
    sema.wait()
}
