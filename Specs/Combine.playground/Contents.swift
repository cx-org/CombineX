import PlaygroundSupport
import Foundation
import Combine

enum CustomError: Error {
    case e1
}

PlaygroundPage.current.needsIndefiniteExecution = true

let sequence = Publishers.Sequence<[Int], Error>(sequence: [0, 1, 2])

var subjects = [
    PassthroughSubject<Int, Error>(),
    PassthroughSubject<Int, Error>(),
    PassthroughSubject<Int, Error>()
]
let pub = sequence
    .flatMap {
        subjects[$0]
    }

print(subjects.map { ObjectIdentifier($0) })

var subscription: Subscription?

var f = false
let sub = AnySubscriber<Int, Error>(receiveSubscription: { (s) in
    print("receive subscription", s)
    subscription = s
}, receiveValue: { v in
    if !f {
        Thread.sleep(forTimeInterval: 1)
        f = true
    }
    print("receive", v, Date())
    return .none
}, receiveCompletion: { c in
    print("receive", c)
})

pub.subscribe(sub)

subscription?.request(.max(1))

//subjects[0].send(1)
//subjects[0].send(2)
//subjects[0].send(3)

//subscription?.request(.max(1))

print("send more")

DispatchQueue.global().async {
    print("send 1", Date())
    subjects[0].send(1)
    print("send 1 end", Date())
}
DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
    
    for i in 0..<1000 {
        subjects[1].send(i)
    }
}

DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
    print("request more")
    subscription?.request(.unlimited)
}

//DispatchQueue.global().async {
//    print("send 3", Date())
//    subjects[0].send(3)
//    print("send 3 end", Date())
//}

//subscription?.request(.max(10))
//
//subjects[1].send(11)
//subjects[1].send(12)
//subjects[1].send(13)
//
//subjects[1].send(completion: .failure(CustomError.e1))
//
//subjects[2].send(21)
//subjects[2].send(22)
//subjects[2].send(23)
//
//subscription?.request(.max(1))

