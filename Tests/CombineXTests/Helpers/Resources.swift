protocol ResourceProtocol: AnyObject {
    
    func release()
}

enum Resources {
    
    class Box: ResourceProtocol {
        weak var obj: ResourceProtocol?
        init(_ obj: ResourceProtocol) {
            self.obj = obj
        }
        
        func release() {
            self.obj?.release()
        }
    }
    
    private static let global = Atom<[ResourceProtocol]>(val: [])
    
    static func resgiter(_ resource: ResourceProtocol) {
        let box = Box(resource)
        self.global.withLockMutating {
            $0.append(box)
        }
    }
    
    static func release() {
        let resources = self.global.exchange(with: [])
        resources.forEach {
            $0.release()
        }
    }
}


