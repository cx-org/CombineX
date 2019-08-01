#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

typealias Demand = Subscribers.Demand
typealias Completion = Subscribers.Completion
