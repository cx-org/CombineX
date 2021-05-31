import CombineX
import MyFramework

_ = foo()
    .sink {
        precondition(1 == $0)
    }
