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
        
        let queue = DispatchQueue(label: "123")
        
        let pub = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3])
        
        let anySub = AnySubscriber<Int, Never>(receiveSubscription: { (s) in
            print("receiveSubscription ison queue", DispatchQueue.isOn(queue))
            
            
            print("receive subscription", s)
            
            print("request value 1")
            s.request(.max(1))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                print("request value 2")
                s.request(.max(1))
            }
            //            print("request value 2")
            //            s.request(.max(1))
            //
            //            print("request value 3")
            //            s.request(.max(1))
        }, receiveValue: { v in
            print("receiveValue ison queue", DispatchQueue.isOn(queue))
            print("receive value", v)
            return .max(1)
        } , receiveCompletion: { completion in
            print("receiveCompletion ison queue", DispatchQueue.isOn(queue))
            print("receive completion", completion)
        })
        
        
        pub.subscribe(on: DispatchQueueScheduler(queue)).subscribe(anySub)

    }


}

