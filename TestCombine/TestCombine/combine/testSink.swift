//
//  Sink.swift
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

func testSink() {
    let sema = DispatchSemaphore(value: 0)
    
    let pub = AnyPublisher<Int, Never> { (sub) in
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            print("[AnyPub] send subscription 0")
            sub.receive(subscription: AnotherSubscription())
            print("[AnyPub] send 0")
            print("[AnyPub] want more", sub.receive(0))
            
            sub.receive(completion: .finished)
            sub.receive(completion: .finished)
            
            print("[AnyPub] want more", sub.receive(1))
            
            print("[AnyPub] send subscription 1")
            sub.receive(subscription: AnotherSubscription())
            print("[AnyPub] send 1")
            print("[AnyPub] want more", sub.receive(1))
            
            sub.receive(completion: .finished)
            
            print("[AnyPub] send 2")
            _ = sub.receive(2)
            
            sema.signal()
        }
    }
    
    let sub = Subscribers.Sink<AnyPublisher<Int, Never>>(receiveCompletion: {
        print("[Sink] receive completion", $0)
    }, receiveValue: {
        print("[Sink] receive value", $0)
    })
    
    print("[Assign] cancel")
    sub.cancel()
    
    pub.subscribe(sub)
    
    ObjectObserver.observe(sub)
    
    sema.wait()
}
