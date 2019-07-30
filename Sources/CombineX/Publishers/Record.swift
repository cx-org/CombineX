/// A publisher that allows for recording a series of inputs and a completion for later playback to each subscriber.
public struct Record<Output, Failure> : Publisher where Failure : Error {

    /// The recorded output and completion.
    public let recording: Record<Output, Failure>.Recording

    /// Interactively record a series of outputs and a completion.
    public init(record: (inout Record<Output, Failure>.Recording) -> Void) {
        Global.RequiresImplementation()
    }

    /// Initialize with a recording.
    public init(recording: Record<Output, Failure>.Recording) {
        Global.RequiresImplementation()
    }

    /// Set up a complete recording with the specified output and completion.
    public init(output: [Output], completion: Subscribers.Completion<Failure>) {
        Global.RequiresImplementation()
    }

    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber {
        Global.RequiresImplementation()
    }

    /// A recorded set of `Output` and a `Subscribers.Completion`.
    public struct Recording {

        public typealias Input = Output

        /// The output which will be sent to a `Subscriber`.
        public var output: [Output] {
            Global.RequiresImplementation()
        }

        /// The completion which will be sent to a `Subscriber`.
        public var completion: Subscribers.Completion<Failure> {
            Global.RequiresImplementation()
        }

        /// Set up a recording in a state ready to receive output.
        public init() {
            Global.RequiresImplementation()
        }

        /// Set up a complete recording with the specified output and completion.
        public init(output: [Output], completion: Subscribers.Completion<Failure> = .finished) {
            Global.RequiresImplementation()
        }

        /// Add an output to the recording.
        ///
        /// A `fatalError` will be raised if output is added after adding completion.
        public mutating func receive(_ input: Record<Output, Failure>.Recording.Input) {
            Global.RequiresImplementation()
        }

        /// Add a completion to the recording.
        ///
        /// A `fatalError` will be raised if more than one completion is added.
        public mutating func receive(completion: Subscribers.Completion<Failure>) {
            Global.RequiresImplementation()
        }
    }
}

extension Record : Codable where Output : Decodable, Output : Encodable, Failure : Decodable, Failure : Encodable {

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        Global.RequiresImplementation()
    }

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        Global.RequiresImplementation()
    }
}

extension Record.Recording : Codable where Output : Decodable, Output : Encodable, Failure : Decodable, Failure : Encodable {

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        Global.RequiresImplementation()
    }

    public func encode(into encoder: Encoder) throws {
        Global.RequiresImplementation()
    }

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        Global.RequiresImplementation()
    }
}

