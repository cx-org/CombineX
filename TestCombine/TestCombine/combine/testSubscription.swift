//
//  testSubscription.swift
//  TestCombine
//
//  Created by Quentin Jin on 2019/6/13.
//  Copyright © 2019 Quentin Jin. All rights reserved.
//

import Foundation
#if CombineQ
import CombineQ
#else
import Combine
#endif

let subscription = AnotherSubscription()

func testSubscription() {
    
    func fn() {
        let pub = AnyPublisher<Int, Never> { (sub) in

            print("[Pub] send subscription")
            sub.receive(subscription: subscription)

            print("[Pub] send value")
            _ = sub.receive(1)

            print("[Pub] send completion")
            sub.receive(completion: .finished)

            print("[Pub] out")
        }
        
        let sub = MySubscriber<Int, Never>(receiveSubscription: { (s) in
            
            debugPrint(s, type(of: s))
            
            print("[AnySub] receive subscription", s)
            
            s.request(.max(-1))
        }, receiveValue: { i in
            print("[AnySub] receive value", i)
            
            return .max(0)
        }, receiveCompletion: {
            print("[AnySub] receive completion", $0)
        })
        
        pub.subscribe(sub)
    }
    
    fn()
    print("fn done")
}

/*
 [Sink] receive value 1
 [Sink] receive completion finished
 [ObjectObserver] Sink deinit
 fn done
 */

public class MySubscriber<Input, Failure> : Subscriber where Failure : Error {
    
    public let combineIdentifier: CombineIdentifier
    
    private let receiveSubscriptionBody: ((Subscription) -> Void)?
    private let receiveValueBody: ((Input) -> Subscribers.Demand)?
    private let receiveCompletionBody: ((Subscribers.Completion<Failure>) -> Void)?

    public init(receiveSubscription: ((Subscription) -> Void)? = nil, receiveValue: ((Input) -> Subscribers.Demand)? = nil, receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil) {
        self.receiveSubscriptionBody = receiveSubscription
        self.receiveValueBody = receiveValue
        self.receiveCompletionBody = receiveCompletion
        
        self.combineIdentifier = CombineIdentifier()
    }
    
    /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
    ///
    /// Use the received `Subscription` to request items from the publisher.
    /// - Parameter subscription: A subscription that represents the connection between publisher and subscriber.
    public func receive(subscription: Subscription) {
        self.receiveSubscriptionBody?(subscription)
    }
    
    /// Tells the subscriber that the publisher has produced an element.
    ///
    /// - Parameter input: The published element.
    /// - Returns: A `Demand` instance indicating how many more elements the subcriber expects to receive.
    public func receive(_ value: Input) -> Subscribers.Demand {
        return self.receiveValueBody?(value) ?? .unlimited
    }
    
    /// Tells the subscriber that the publisher has completed publishing, either normally or with an error.
    ///
    /// - Parameter completion: A `Completion` case indicating whether publishing completed normally or with an error.
    public func receive(completion: Subscribers.Completion<Failure>) {
        self.receiveCompletionBody?(completion)
    }
    
    deinit {
        print("[My Subscription] deinit")
    }
}
