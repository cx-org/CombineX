import CXShim
import CXUtility
import Foundation
import Dispatch

extension DispatchQueue {
    
    public func concurrentPerform(iterations: Int, execute work: (Int) -> Void) {
        withoutActuallyEscaping(work) { w in
            let g = DispatchGroup()
            for i in 0..<iterations {
                async(group: g) {
                    w(i)
                }
            }
            g.wait()
        }
    }
    
    public var isCurrent: Bool {
        let key = DispatchSpecificKey<Void>()
        self.setSpecific(key: key, value: ())
        defer {
            self.setSpecific(key: key, value: nil)
        }
        return DispatchQueue.getSpecific(key: key) != nil
    }
}

extension CXWrappers.DispatchQueue.SchedulerTimeType.Stride {
    
    public var seconds: TimeInterval {
        return TimeInterval(magnitude) / TimeInterval(Const.nsec_per_sec)
    }
}
