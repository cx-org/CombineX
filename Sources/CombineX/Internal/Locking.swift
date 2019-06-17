import Foundation

extension NSLocking {
    
    func withLock<T>(_ body: @escaping () -> T) -> T {
        self.lock()
        defer {
            self.unlock()
        }
        return body()
    }
}
