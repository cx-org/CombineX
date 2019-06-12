//
//  ViewController.swift
//  TestCombine
//
//  Created by Quentin Jin on 2019/6/12.
//  Copyright © 2019 Quentin Jin. All rights reserved.
//

import UIKit
import Combine

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        testAssign()
    }
    
    func testAssign() {
        let pub = AnyPublisher<Int, Never> { (sub) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let subcription = AnotherEmptySubscription()
                
                print("send subscription 0")
                sub.receive(subscription: subcription)
                print("send 0")
                print("want more", sub.receive(0))
            
                sub.receive(completion: .finished)
                
                print("send subscription 1")
                sub.receive(subscription: subcription)
                print("send 1")
                print("want more", sub.receive(1))
                
                sub.receive(completion: .finished)
                
//                sub.receive(2)
            }
        }
//        let pub = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3])
        
        class Box {
            var age: Int = 0 {
                didSet {
                    print("did set age", age, oldValue)
                }
            }
        }
        
        var box = Box()
        let sub = Subscribers.Assign<Box, Int>(object: box, keyPath: \.age)
        
//        let sub = Subscribers.Sink<AnyPublisher<Int, Never>>.init(receiveCompletion: { (completion) in
//            print("recevie completion", completion)
//        }, receiveValue: {
//            print("receive value", $0)
//        })
        
        ObjectObserver.observe(sub)
        
        print("cancel")
        sub.cancel()
        pub.subscribe(sub)
    }
    
    func testAllAny() {
        let pub = AnyPublisher<Int, Never> { (sub) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                sub.receive(subscription: AnotherEmptySubscription())
                print("send 1")
                print("want more", sub.receive(1))
                
                sub.receive(completion: .finished)
                
                sub.receive(2)
            }
        }
        
        let anySub = AnySubscriber<Int, Never>(receiveSubscription: { (s) in
            
            print("receive subscription", s)
            
            print("subscription request value 1")
            s.request(.max(1))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                print("request value 2")
                s.request(.max(1))
            }
            
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            //                print("request value 3")
            //                s.request(.max(1))
            //            }
            //                        print("request value 2")
            //                        s.request(.max(1))
            //
            //                        print("request value 3")
            //                        s.request(.max(1))
        }, receiveValue: { v in
            print("receive value", v)
            
            let id = Int.random(in: 0..<100)
            print("this queue is going to be blocked for 5s", id)
            Thread.sleep(forTimeInterval: 5)
            print("this queue passed the block", id)
            return .max(0)
        } , receiveCompletion: { completion in
            print("receive completion", completion)
        })
        
        
        pub.subscribe(anySub)
    }
    
    func anySubscriber() {
        let queue = DispatchQueue(label: "abc")
        
        let pub = Publishers.Sequence<[Int], Never>(sequence: [1, 2])
            .map { $0 }
//        let pub = Publishers.Just(1)
        
        let anySub = AnySubscriber<Int, Never>(receiveSubscription: { (s) in
            
            print("receiveSubscription is on queue", DispatchQueue.isOn(queue))
            
            print("receive subscription", s)
            
            print("subscription request value 1")
            s.request(.max(1))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                print("request value 2")
                s.request(.max(1))
            }

//            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
//                print("request value 3")
//                s.request(.max(1))
//            }
            //                        print("request value 2")
            //                        s.request(.max(1))
            //
            //                        print("request value 3")
            //                        s.request(.max(1))
        }, receiveValue: { v in
            print("receiveValue is on queue", DispatchQueue.isOn(queue))
            print("receive value", v)

            let id = Int.random(in: 0..<100)
            print("this queue is going to be blocked for 5s", id)
            Thread.sleep(forTimeInterval: 5)
            print("this queue passed the block", id)
            return .max(0)
        } , receiveCompletion: { completion in
            print("receiveCompletion is on queue", DispatchQueue.isOn(queue))
            print("receive completion", completion)
        })
        
        
        pub.subscribe(on: DispatchQueueScheduler(queue)).subscribe(anySub)
    }
}

