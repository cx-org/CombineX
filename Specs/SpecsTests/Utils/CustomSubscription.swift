#if CombineX
import CombineX
#else
import Combine
#endif

class CustomSubscription: Subscription {
    
    var requestBody: ((Subscribers.Demand) -> Void)?
    var cancelBody: (() -> Void)?
    
    init(request: ((Subscribers.Demand) -> Void)? = nil, cancel: (() -> Void)? = nil) {
        self.requestBody = request
        self.cancelBody = cancel
    }
    
    func request(_ demand: Subscribers.Demand) {
        self.requestBody?(demand)
    }
    
    func cancel() {
        self.cancelBody?()
    }
}
