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
    
    let pub = URLSession.shared.dataTaskPublisher(for: URL(string: "http://localhost:3000")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
