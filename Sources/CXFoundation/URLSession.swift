import Foundation
import CombineX

extension CombineXWrapper where Base: URLSession {
    
    /// Returns a publisher that wraps a URL session data task for a given URL.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    /// - Parameter url: The URL for which to create a data task.
    /// - Returns: A publisher that wraps a data task for the URL.
    public func dataTaskPublisher(for url: URL) -> URLSession.CX.DataTaskPublisher {
        return self.dataTaskPublisher(for: URLRequest(url: url))
    }

    /// Returns a publisher that wraps a URL session data task for a given URL request.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    /// - Parameter request: The URL request for which to create a data task.
    /// - Returns: A publisher that wraps a data task for the URL request.
    public func dataTaskPublisher(for request: URLRequest) -> URLSession.CX.DataTaskPublisher {
        return .init(request: request, session: self.base)
    }
}


extension URLSession.CX {
    
    public struct DataTaskPublisher : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = (data: Data, response: URLResponse)

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = URLError

        public let request: URLRequest

        public let session: URLSession

        public init(request: URLRequest, session: URLSession) {
            self.request = request
            self.session = session
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Failure, S.Input == Output {
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
