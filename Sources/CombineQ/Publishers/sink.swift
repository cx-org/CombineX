extension Publisher {
    
    /// Attaches a subscriber with closure-based behavior.
    ///
    /// This method creates the subscriber and immediately requests an unlimited number of values, prior to returning the subscriber.
    /// - parameter receiveValue: The closure to execute on receipt of a value. If `nil`, the sink uses an empty closure.
    /// - parameter receiveComplete: The closure to execute on completion. If `nil`, the sink uses an empty closure.
    /// - Returns: A subscriber that performs the provided closures upon receiving values or completion.
    public func sink(receiveCompletion: ((Subscribers.Completion<Self.Failure>) -> Void)? = nil, receiveValue: @escaping ((Self.Output) -> Void)) -> Subscribers.Sink<Self> {
        let sink = Subscribers.Sink<Self>(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
        self.subscribe(sink)
        
        #warning("Not like `assign`, it returns a `Sink`.")
        return sink
    }
}
