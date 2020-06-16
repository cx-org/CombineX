import CXUtility

public protocol TestResourceProtocol: AnyObject {
    
    func release()
}

public enum TestResources {
    
    private class Box: TestResourceProtocol {
        weak var obj: TestResourceProtocol?
        init(_ obj: TestResourceProtocol) {
            self.obj = obj
        }
        
        func release() {
            self.obj?.release()
        }
    }
    
    private static let global = LockedAtomic<[TestResourceProtocol]>([])
    
    public static func resgiter(_ resource: TestResourceProtocol) {
        let box = Box(resource)
        self.global.withLockMutating {
            $0.append(box)
        }
    }
    
    public static func release() {
        let resources = self.global.exchange([])
        resources.forEach {
            $0.release()
        }
    }
}
