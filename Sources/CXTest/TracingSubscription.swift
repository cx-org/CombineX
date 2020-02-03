import CXShim
import CXUtility

public class TracingSubscription: Subscription {
    
    public enum Event: Equatable, Hashable {
        case request(demand: Subscribers.Demand)
        case cancel
    }
    
    private let _lock = Lock()
    private var _events: [Event] = []
    
    private let _rcvRequest: ((Subscribers.Demand) -> Void)?
    private let _rcvCancel: (() -> Void)?
    private let _onDeinit: (() -> Void)?
    
    public var events: [Event] {
        return self._lock.withLockGet(self._events)
    }
    
    public init(receiveRequest: ((Subscribers.Demand) -> Void)? = nil, receiveCancel: (() -> Void)? = nil, onDeinit: (() -> Void)? = nil) {
        self._rcvRequest = receiveRequest
        self._rcvCancel = receiveCancel
        self._onDeinit = onDeinit
    }
    
    public func request(_ demand: Subscribers.Demand) {
        self._lock.withLock {
            self._events.append(.request(demand: demand))
        }
        self._rcvRequest?(demand)
    }
    
    public func cancel() {
        self._lock.withLock {
            self._events.append(.cancel)
        }
        self._rcvCancel?()
    }
}
