import Foundation
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
        
        it("should complete when a sub-publisher send an error") {
            let sequence = Publishers.Sequence<[Int], CustomError>(sequence: [0, 1, 2])
            
            let subjects = [
                PassthroughSubject<Int, CustomError>(),
                PassthroughSubject<Int, CustomError>(),
                PassthroughSubject<Int, CustomError>(),
            ]
            
            let pub = sequence
                .flatMap {
                    return subjects[$0]
                }
            
            let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { s in
                s.request(.max(1))
            }, receiveValue: { v in
                return .max(1)
            }, receiveCompletion: { c in
            })
            
            pub.subscribe(sub)
            
            3.times {
                subjects[0].send(0)
                subjects[1].send(1)
                subjects[2].send(2)
            }
            
            subjects[1].send(completion: .failure(.e1))
            
            3.times {
                subjects[0].send(0)
                subjects[1].send(1)
                subjects[2].send(2)
            }
            
            expect(sub._events.count).to(equal(10))

            var events = [0, 1, 2].flatMap { _ in [0, 1, 2] }.map { CustomSubscriber<Int, CustomError>.Event.value($0) }
            events.append(CustomSubscriber<Int, CustomError>.Event.completion(.failure(.e1)))

            expect(sub._events).to(equal(events))
        }
        
        it("should work well when concurrent flatmap") {
            let sequence = Publishers.Sequence<[Int], Never>(sequence: [0, 1, 2])

            let subjects = [
                PassthroughSubject<Int, Never>(),
                PassthroughSubject<Int, Never>(),
                PassthroughSubject<Int, Never>(),
            ]
            
            let pub = sequence.flatMap { (i) -> PassthroughSubject<Int, Never> in
                return subjects[i]
            }
            
            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { s in
                s.request(.max(10))
            }, receiveValue: { v in
                print("receive v", v)
                return .none
            }, receiveCompletion: { c in
            })

            pub.subscribe(sub)
            
            let g = DispatchGroup()
            
            20.times { i in
                DispatchQueue.global().async(group: g) {
                    subjects.randomElement()!.send(i)
                }
            }
            
            g.wait()
            
            expect(sub.events.count).to(equal(10))
        }
    }
}
