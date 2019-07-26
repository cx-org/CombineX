#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

extension Publisher {
    
    /// Raises a debugger signal when a provided closure needs to stop the process in the debugger.
    ///
    /// When any of the provided closures returns `true`, this publisher raises the `SIGTRAP` signal to stop the process in the debugger.
    /// Otherwise, this publisher passes through values and completions as-is.
    ///
    /// - Parameters:
    ///   - receiveSubscription: A closure that executes when when the publisher receives a subscription. Return `true` from this closure to raise `SIGTRAP`, or false to continue.
    ///   - receiveOutput: A closure that executes when when the publisher receives a value. Return `true` from this closure to raise `SIGTRAP`, or false to continue.
    ///   - receiveCompletion: A closure that executes when when the publisher receives a completion. Return `true` from this closure to raise `SIGTRAP`, or false to continue.
    /// - Returns: A publisher that raises a debugger signal when one of the provided closures returns `true`.
    public func breakpoint(receiveSubscription: ((Subscription) -> Bool)? = nil, receiveOutput: ((Self.Output) -> Bool)? = nil, receiveCompletion: ((Subscribers.Completion<Self.Failure>) -> Bool)? = nil) -> Publishers.Breakpoint<Self> {
        return .init(upstream: self, receiveSubscription: receiveSubscription, receiveOutput: receiveOutput, receiveCompletion: receiveCompletion)
    }
    
    /// Raises a debugger signal upon receiving a failure.
    ///
    /// When the upstream publisher fails with an error, this publisher raises the `SIGTRAP` signal, which stops the process in the debugger.
    /// Otherwise, this publisher passes through values and completions as-is.
    /// - Returns: A publisher that raises a debugger signal upon receiving a failure.
    public func breakpointOnError() -> Publishers.Breakpoint<Self> {
        return .init(upstream: self, receiveSubscription: nil, receiveOutput: nil, receiveCompletion: { completion in
            switch completion {
            case .finished:     return false
            case .failure:      return true
            }
        })
    }
}

extension Publishers {
    
    /// A publisher that raises a debugger signal when a provided closure needs to stop the process in the debugger.
    ///
    /// When any of the provided closures returns `true`, this publisher raises the `SIGTRAP` signal to stop the process in the debugger.
    /// Otherwise, this publisher passes through values and completions as-is.
    public struct Breakpoint<Upstream> : Publisher where Upstream : Publisher {
        
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// A closure that executes when the publisher receives a subscription, and can raise a debugger signal by returning a true Boolean value.
        public let receiveSubscription: ((Subscription) -> Bool)?
        
        /// A closure that executes when the publisher receives output from the upstream publisher, and can raise a debugger signal by returning a true Boolean value.
        public let receiveOutput: ((Upstream.Output) -> Bool)?
        
        /// A closure that executes when the publisher receives completion, and can raise a debugger signal by returning a true Boolean value.
        public let receiveCompletion: ((Subscribers.Completion<Upstream.Failure>) -> Bool)?
        
        /// Creates a breakpoint publisher with the provided upstream publisher and breakpoint-raising closures.
        ///
        /// - Parameters:
        ///   - upstream: The publisher from which this publisher receives elements.
        ///   - receiveSubscription: A closure that executes when the publisher receives a subscription, and can raise a debugger signal by returning a true Boolean value.
        ///   - receiveOutput: A closure that executes when the publisher receives output from the upstream publisher, and can raise a debugger signal by returning a true Boolean value.
        ///   - receiveCompletion: A closure that executes when the publisher receives completion, and can raise a debugger signal by returning a true Boolean value.
        public init(upstream: Upstream, receiveSubscription: ((Subscription) -> Bool)? = nil, receiveOutput: ((Upstream.Output) -> Bool)? = nil, receiveCompletion: ((Subscribers.Completion<Publishers.Breakpoint<Upstream>.Failure>) -> Bool)? = nil) {
            self.upstream = upstream
            self.receiveSubscription = receiveSubscription
            self.receiveOutput = receiveOutput
            self.receiveCompletion = receiveCompletion
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {

            self.upstream
                .handleEvents(receiveSubscription: { s in
                    if let body = self.receiveSubscription, body(s) {
                        Signal.sigtrap.raise()
                    }
                }, receiveOutput: { v in
                    if let body = self.receiveOutput, body(v) {
                        Signal.sigtrap.raise()
                    }
                }, receiveCompletion: { c in
                    if let body = self.receiveCompletion, body(c) {
                        Signal.sigtrap.raise()
                    }
                })
                .receive(subscriber: subscriber)
        }
    }
}

private enum Signal {
    
    case sigtrap
    
    var code: Int32 {
        switch self {
        case .sigtrap:  return Int32(SIGTRAP)
        }
    }
    
    func raise() {
        #if canImport(Darwin)
        Darwin.raise(self.code)
        #elseif canImport(Glibc)
        Glibc.raise(self.code)
        #else
        Global.Unsupported()
        #endif
    }
}
