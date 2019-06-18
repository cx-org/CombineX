import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class OnceTests: XCTestCase {
    
    func testShouldSendValueThenSendCompletion() {
        let once = Publishers.Once<Int, CustomError>(.success(1))
        var count = 0
        _ = once.sink(
            receiveCompletion: { (completion) in
                count += 1
                XCTAssertTrue(completion.isFinished)
        },
            receiveValue: { value in
                count += 1
                XCTAssertEqual(value, 1)
        }
        )
        
        XCTAssertEqual(count, 2)
    }
    
    func testShouldSendError() {
        let once = Publishers.Once<Int, CustomError>(.failure(.e0))
        var count = 0
        _ = once.sink(
            receiveCompletion: { (completion) in
                count += 1
                XCTAssertTrue(completion.isFailure)
            },
            receiveValue: { value in
                count += 1
                XCTAssertEqual(value, 1)
            }
        )
        
        XCTAssertEqual(count, 1)
    }
    
    func testShouldFreeSubWhenComplete() {
        let once = Publishers.Once<Int, CustomError>(.success(1))
        
        weak var subscriber: CustomSubscriber<Int, CustomError>?
        
        do {
            let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                s.request(.max(1))
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { s in
            })
            
            subscriber = sub
            once.subscribe(sub)
        }
        
        XCTAssertNil(subscriber)
    }
    
    func testConcurrent() {
        let once = Publishers.Once<Int, CustomError>(.success(1))
        
        var count = 0
        
        let g = DispatchGroup()
        let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
            for _ in 0..<100 {
                g.enter()
                DispatchQueue.global().async {
                    g.leave()
                    s.request(.max(1))
                }
            }
        }, receiveValue: { v in
            count += 1
            return .none
        }, receiveCompletion: { c in
        })
        
        once.subscribe(sub)
        
        g.wait()
        
        XCTAssertEqual(count, 1)
    }
}
