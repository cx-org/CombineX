//
//  ViewController.swift
//  CombineSpecs
//
//  Created by Quentin Jin on 2019/6/16.
//  Copyright © 2019 Quentin Jin. All rights reserved.
//

import UIKit
import Combine

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let sequence = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3])

        let pub = sequence.flatMap { (i) -> PassthroughSubject<Int, Never> in
            let subject = PassthroughSubject<Int, Never>()
            
            let g = DispatchGroup()
            for _ in 0..<3 {
                DispatchQueue.global().async(group: g) {
                    print("send", i)
                    subject.send(i)
                }
            }
            
            g.notify(queue: .global()) {
                print("send finish", i)
                subject.send(completion: .finished)
            }
            
            return subject
        }
        
        let sub = AnySubscriber<Int, Never>(receiveSubscription: { (s) in
            s.request(.max(8))
        }, receiveValue: { (i) -> Subscribers.Demand in
            print("receive", i)
            return .none
        }, receiveCompletion: { c in
            print("receive", c)
        })
        
        pub.subscribe(sub)
    }


}

