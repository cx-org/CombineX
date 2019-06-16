//
//  ViewController.swift
//  TestCombine
//
//  Created by Quentin Jin on 2019/6/12.
//  Copyright © 2019 Quentin Jin. All rights reserved.
//

import UIKit
#if CombineQ
import CombineQ
#else
import Combine
#endif

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        testSink()
    }
}
