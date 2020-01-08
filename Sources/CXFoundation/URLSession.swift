import CombineX
import CXUtility
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

#if !COCOAPODS
import CXNamespace
#endif

extension CXWrappers {
    
    #if canImport(FoundationNetworking)
    public final class URLSession: NSObject<FoundationNetworking.URLSession> {}
    #else
    public final class URLSession: NSObject<Foundation.URLSession> {}
    #endif
}

extension URLSession {
    
    typealias CX = CXWrappers.URLSession
    
    public var cx: CXWrappers.URLSession {
        return CXWrappers.URLSession(wrapping: self)
    }
}

extension CXWrappers.URLSession {
    
    /// Returns a publisher that wraps a URL session data task for a given URL.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    /// - Parameter url: The URL for which to create a data task.
    /// - Returns: A publisher that wraps a data task for the URL.
    public func dataTaskPublisher(for url: URL) -> DataTaskPublisher {
        return self.dataTaskPublisher(for: URLRequest(url: url))
    }
    
    /// Returns a publisher that wraps a URL session data task for a given URL request.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    /// - Parameter request: The URL request for which to create a data task.
    /// - Returns: A publisher that wraps a data task for the URL request.
    public func dataTaskPublisher(for request: URLRequest) -> DataTaskPublisher {
        return .init(request: request, session: self.base)
    }
}

extension CXWrappers.URLSession {
    
    public struct DataTaskPublisher: Publisher {
        
        public typealias Output = (data: Data, response: URLResponse)
        
        public typealias Failure = URLError
        
        public let request: URLRequest
        
        public let session: URLSession
        
        public init(request: URLRequest, session: URLSession) {
            self.request = request
            self.session = session
        }
        
        public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
            let subscription = Inner(parent: self, downstream: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

private extension CXWrappers.URLSession.DataTaskPublisher {
    
    final class Inner<Downstream: Subscriber>: Subscription where Downstream.Input == (data: Data, response: URLResponse),
              Downstream.Failure == URLError {
        
        let lock = Lock()
        
        var parent: CXWrappers.URLSession.DataTaskPublisher?
        
        var downstream: Downstream?
        
        var demand = Subscribers.Demand.none
        
        var task: URLSessionDataTask?
        
        init(parent: CXWrappers.URLSession.DataTaskPublisher, downstream: Downstream) {
            self.parent = parent
            self.downstream = downstream
        }
        
        func request(_ demand: Subscribers.Demand) {
            lock.withLock { () -> URLSessionDataTask? in
                guard let parent = self.parent else {
                    return nil
                }
                self.demand += demand
                if self.demand > 0, task == nil {
                    task = parent.session.dataTask(with: parent.request, completionHandler: handleResponse)
                    return task
                } else {
                    return nil
                }
            }?.resume()
        }
        
        func cancel() {
            lock.withLock { () -> URLSessionDataTask? in
                guard parent != nil else {
                    return nil
                }
                defer {
                    parent = nil
                    downstream = nil
                    task = nil
                }
                return task
            }?.cancel()
        }
        
        func handleResponse(data: Data?, response: URLResponse?, error: Error?) {
            lock.lock()
            guard demand > 0, parent != nil, let downstream = self.downstream else {
                lock.unlock()
                return
            }
            self.demand = .none
            self.parent = nil
            self.downstream = nil
            self.task = nil
            lock.unlock()
            
            switch (data, response, error) {
            case let (_, response?, nil):
                _ = downstream.receive((data ?? Data(), response))
                downstream.receive(completion: .finished)
            case let (_, _, error as URLError):
                downstream.receive(completion: .failure(error))
            default:
                downstream.receive(completion: .failure(URLError(.unknown)))
            }
        }
    }
}
