import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class FlatMapSpec: QuickSpec {
    
    override func spec() {
        
        it("should receive sub-subscriber's value") {
            let sequence = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3])
            
            let pub = sequence
                .flatMap {
                    Publishers.Sequence<[Int], Never>(sequence: [$0, $0, $0])
            }
            
            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { s in
                s.request(.unlimited)
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
            
            pub.subscribe(sub)
            
            expect(sub._events.count).to(equal(10))
        }
        
        it("should receive value as demand") {
            let sequence = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3, 4, 5])
            
            let pub = sequence
                .flatMap {
                    Publishers.Sequence<[Int], Never>(sequence: [$0, $0, $0])
                }
                .flatMap {
                    Publishers.Sequence<[Int], Never>(sequence: [$0, $0, $0])
                }
            
            var received = Subscribers.Demand.max(0)
            
            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { s in
                s.request(.max(1))
            }, receiveValue: { v in
                received += .max(1)
                
                if received == .max(10) {
                    return .none
                }
                
                return .max(1)
            }, receiveCompletion: { c in
            })
            
            pub.subscribe(sub)
            
            expect(sub._events.count).to(equal(received.max))
        }
        
        // MARK: Combine's behavior is strange.
        xit("should complete when a sub-publisher send an error") {
            let sequence = Publishers.Sequence<[Int], CustomError>(sequence: [1, 2, 3, 4, 5])
            
            let pub = sequence
                .flatMap { i -> AnyPublisher<Int, CustomError> in
                    if i == 4 {
                        return Publishers.Once<Int, CustomError>(.failure(CustomError.e1)).eraseToAnyPublisher()
                    }
                    return Publishers.Sequence<[Int], CustomError>(sequence: [i, i, i]).eraseToAnyPublisher()
                }
            
            let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { s in
                s.request(.max(1))
            }, receiveValue: { v in
                return .max(1)
            }, receiveCompletion: { c in
            })
            
            pub.subscribe(sub)
            
            expect(sub._events.count).to(equal(10))

            var events = [1, 2, 3].flatMap { [$0, $0, $0] }.map { CustomSubscriber<Int, CustomError>.Event.value($0) }
            events.append(CustomSubscriber<Int, CustomError>.Event.completion(.failure(.e1)))

            expect(sub._events).to(equal(events))
        }
        
        fit("should work well when concurrent flatmap") {
            let sequence = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3])

            let sema = DispatchSemaphore(value: 0)
            
            let pub = sequence.flatMap { (i) -> PassthroughSubject<Int, Never> in
                let subject = PassthroughSubject<Int, Never>()
            
                let g = DispatchGroup()
                for _ in 0..<3 {
                    g.enter()
                    DispatchQueue.global().async {
                        subject.send(i)
                        g.leave()
                    }
                }
                
                g.notify(queue: .global()) {
                    subject.send(completion: .finished)
                }
                
                return subject
            }
            
            pub.sink(receiveCompletion: { (c) in
                print("receive c", c)
                sema.signal()
            }, receiveValue: { v in
                print("receive v", v)
            })
            
//            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { s in
//                s.request(.max(1))
//            }, receiveValue: { v in
//                print("receive value", v)
//                return .max(1)
//            }, receiveCompletion: { c in
//                print("receive completion", c)
//                sema.signal()
//            })
//
//            pub.subscribe(sub)

            sema.wait()
            
//            print(sub.events)
        }
    }
}
