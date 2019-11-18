import Foundation
import CombineX

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
            let subject = PassthroughSubject<Output, Failure>()
            let task = self.session.dataTask(with: self.request) { (data, response, error) in
                if let e = error as? URLError {
                    subject.send(completion: .failure(e))
                    return
                }

                guard let d = data, let r = response else {
                    fatalError()
                }
                subject.send((d, r))
                subject.send(completion: .finished)
            }
            task.resume()
            
            subject
                .handleEvents(receiveCancel: {
                    task.cancel()
                })
                .receive(subscriber: subscriber)
        }
    }
}
