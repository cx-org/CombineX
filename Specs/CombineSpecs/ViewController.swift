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
        
        enum E: Error {
            case e
        }
        
        let sub = PassthroughSubject<Int, E>()
        sub.assertNoFailure("[q]")
            .sink(receiveCompletion: { (c) in
                print("completion", c)
            }, receiveValue: { v in
                print("value", v)
            })
        sub.send(1)
        sub.send(completion: .failure(E.e))
    }
}

