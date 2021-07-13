import MyFramework
import Foundation


func foo() async -> Int {
    print(Thread.current)
    return 1
}

dispatchMain()
