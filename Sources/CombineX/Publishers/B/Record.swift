/// A publisher that allows for recording a series of inputs and a completion for later playback to each subscriber.
public struct Record<Output, Failure: Error>: Publisher {
    
    /// The recorded output and completion.
    public let recording: Record<Output, Failure>.Recording
    
    /// Interactively record a series of outputs and a completion.
    public init(record: (inout Record<Output, Failure>.Recording) -> Void) {
        var recording = Recording()
        record(&recording)
        self.recording = recording
    }
    
    /// Initialize with a recording.
    public init(recording: Record<Output, Failure>.Recording) {
        self.recording = recording
    }
    
    /// Set up a complete recording with the specified output and completion.
    public init(output: [Output], completion: Subscribers.Completion<Failure>) {
        self.recording = .init(output: output, completion: completion)
    }
    
    public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Failure == S.Failure {
        let pub = self.recording.output.cx.publisher.setFailureType(to: Failure.self)
        switch self.recording.completion {
        case .finished:
            pub.receive(subscriber: subscriber)
        case .failure(let e):
            pub.append(Fail(error: e)).receive(subscriber: subscriber)
        }
    }
    
    /// A recorded set of `Output` and a `Subscribers.Completion`.
    public struct Recording {
        
        public typealias Input = Output
        
        private var isCompleted = false
        
        /// The output which will be sent to a `Subscriber`.
        public private(set) var output: [Output]
        
        /// The completion which will be sent to a `Subscriber`.
        public private(set) var completion: Subscribers.Completion<Failure>
        
        /// Set up a recording in a state ready to receive output.
        public init() {
            self.output = []
            self.completion = .finished
        }
        
        /// Set up a complete recording with the specified output and completion.
        public init(output: [Output], completion: Subscribers.Completion<Failure> = .finished) {
            self.output = output
            self.completion = completion
            self.isCompleted = true
        }
        
        /// Add an output to the recording.
        ///
        /// A `fatalError` will be raised if output is added after adding completion.
        public mutating func receive(_ input: Record<Output, Failure>.Recording.Input) {
            precondition(!self.isCompleted)
            self.output.append(input)
        }
        
        /// Add a completion to the recording.
        ///
        /// A `fatalError` will be raised if more than one completion is added.
        public mutating func receive(completion: Subscribers.Completion<Failure>) {
            precondition(!self.isCompleted)
            self.completion = completion
            self.isCompleted = true
        }
    }
}

extension Record: Codable where Output: Decodable, Output: Encodable, Failure: Decodable, Failure: Encodable {}

extension Record.Recording: Codable where Output: Decodable, Output: Encodable, Failure: Decodable, Failure: Encodable {

    // FIXME: Combine has this, what's the diff from `encode(to:)`?
    public func encode(into encoder: Encoder) throws {
        try self.encode(to: encoder)
    }
}
