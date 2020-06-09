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
}
