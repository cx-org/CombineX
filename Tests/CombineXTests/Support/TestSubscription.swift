#if USE_COMBINE
import Combine
#else
import CombineX
#endif

enum TestSubscriptionEvent {
    case request(demand: Subscribers.Demand)
    case cancel
}

class TestSubscription: Subscription, TestLogging {
    
    typealias Event = TestSubscriptionEvent
    
    let name: String?
    let requestBody: ((Subscribers.Demand) -> Void)?
    let cancelBody: (() -> Void)?
    
    private let lock = Lock()
    private var _events: [Event] = []
    
    var events: [Event] {
        return self.lock.withLockGet(self._events)
    }
    
    init(name: String? = nil, request: ((Subscribers.Demand) -> Void)? = nil, cancel: (() -> Void)? = nil) {
        self.name = name
        self.requestBody = request
        self.cancelBody = cancel
    }
    
    func request(_ demand: Subscribers.Demand) {
        self.trace("request demand", demand)
        self.lock.withLock {
            self._events.append(.request(demand: demand))
        }
        self.requestBody?(demand)
    }
    
    func cancel() {
        self.trace("cancel")
        self.lock.withLock {
            self._events.append(.cancel)
        }
        self.cancelBody?()
    }
    
    deinit {
        self.trace("deinit")
    }
}


extension TestSubscriptionEvent: Equatable {
    
    static func == (a: TestSubscriptionEvent, b: TestSubscriptionEvent) -> Bool {
        switch (a, b) {
        case (.request(let d0), .request(let d1)):
            return d0 == d1
        case (.cancel, .cancel):
            return true
        default:
            return false
        }
    }
}
