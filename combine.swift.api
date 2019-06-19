import Darwin


extension Publisher {

    public func multicast<S>(_ createSubject: @escaping () -> S) -> Publishers.Multicast<Self, S> where S : Subject, Self.Failure == S.Failure, Self.Output == S.Output

    public func multicast<S>(subject: S) -> Publishers.Multicast<Self, S> where S : Subject, Self.Failure == S.Failure, Self.Output == S.Output
}

extension Publisher {

    /// Measures and emits the time interval between events received from an upstream publisher.
    ///
    /// The output type of the returned scheduler is the time interval of the provided scheduler.
    /// - Parameters:
    ///   - scheduler: The scheduler on which to deliver elements.
    ///   - options: Options that customize the delivery of elements.
    /// - Returns: A publisher that emits elements representing the time interval between the elements it receives.
    public func measureInterval<S>(using scheduler: S, options: S.SchedulerOptions? = nil) -> Publishers.MeasureInterval<Self, S> where S : Scheduler
}

extension Publisher {

    /// Omits elements from the upstream publisher until a given closure returns false, before republishing all remaining elements.
    ///
    /// - Parameter predicate: A closure that takes an element as a parameter and returns a Boolean
    /// value indicating whether to drop the element from the publisher’s output.
    /// - Returns: A publisher that skips over elements until the provided closure returns `false`.
    public func drop(while predicate: @escaping (Self.Output) -> Bool) -> Publishers.DropWhile<Self>

    /// Omits elements from the upstream publisher until an error-throwing closure returns false, before republishing all remaining elements.
    ///
    /// If the predicate closure throws, the publisher fails with an error.
    ///
    /// - Parameter predicate: A closure that takes an element as a parameter and returns a Boolean value indicating whether to drop the element from the publisher’s output.
    /// - Returns: A publisher that skips over elements until the provided closure returns `false`, and then republishes all remaining elements. If the predicate closure throws, the publisher fails with an error.
    public func tryDrop(while predicate: @escaping (Self.Output) throws -> Bool) -> Publishers.TryDropWhile<Self>
}

extension Publisher {

    /// Republishes all elements that match a provided closure.
    ///
    /// - Parameter isIncluded: A closure that takes one element and returns a Boolean value indicating whether to republish the element.
    /// - Returns: A publisher that republishes all elements that satisfy the closure.
    public func filter(_ isIncluded: @escaping (Self.Output) -> Bool) -> Publishers.Filter<Self>

    /// Republishes all elements that match a provided error-throwing closure.
    ///
    /// If the `isIncluded` closure throws an error, the publisher fails with that error.
    ///
    /// - Parameter isIncluded:  A closure that takes one element and returns a Boolean value indicating whether to republish the element.
    /// - Returns:  A publisher that republishes all elements that satisfy the closure.
    public func tryFilter(_ isIncluded: @escaping (Self.Output) throws -> Bool) -> Publishers.TryFilter<Self>
}

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
    public func breakpoint(receiveSubscription: ((Subscription) -> Bool)? = nil, receiveOutput: ((Self.Output) -> Bool)? = nil, receiveCompletion: ((Subscribers.Completion<Self.Failure>) -> Bool)? = nil) -> Publishers.Breakpoint<Self>

    /// Raises a debugger signal upon receiving a failure.
    ///
    /// When the upstream publisher fails with an error, this publisher raises the `SIGTRAP` signal, which stops the process in the debugger.
    /// Otherwise, this publisher passes through values and completions as-is.
    /// - Returns: A publisher that raises a debugger signal upon receiving a failure.
    public func breakpointOnError() -> Publishers.Breakpoint<Self>
}

extension Publisher {

    /// Publishes a single Boolean value that indicates whether all received elements pass a given predicate.
    ///
    /// When this publisher receives an element, it runs the predicate against the element. If the predicate returns `false`, the publisher produces a `false` value and finishes. If the upstream publisher finishes normally, this publisher produces a `true` value and finishes.
    /// As a `reduce`-style operator, this publisher produces at most one value.
    /// Backpressure note: Upon receiving any request greater than zero, this publisher requests unlimited elements from the upstream publisher.
    /// - Parameter predicate: A closure that evaluates each received element. Return `true` to continue, or `false` to cancel the upstream and complete.
    /// - Returns: A publisher that publishes a Boolean value that indicates whether all received elements pass a given predicate.
    public func allSatisfy(_ predicate: @escaping (Self.Output) -> Bool) -> Publishers.AllSatisfy<Self>

    /// Publishes a single Boolean value that indicates whether all received elements pass a given error-throwing predicate.
    ///
    /// When this publisher receives an element, it runs the predicate against the element. If the predicate returns `false`, the publisher produces a `false` value and finishes. If the upstream publisher finishes normally, this publisher produces a `true` value and finishes. If the predicate throws an error, the publisher fails, passing the error to its downstream.
    /// As a `reduce`-style operator, this publisher produces at most one value.
    /// Backpressure note: Upon receiving any request greater than zero, this publisher requests unlimited elements from the upstream publisher.
    /// - Parameter predicate:  A closure that evaluates each received element. Return `true` to continue, or `false` to cancel the upstream and complete. The closure may throw, in which case the publisher cancels the upstream publisher and fails with the thrown error.
    /// - Returns:  A publisher that publishes a Boolean value that indicates whether all received elements pass a given predicate.
    public func tryAllSatisfy(_ predicate: @escaping (Self.Output) throws -> Bool) -> Publishers.TryAllSatisfy<Self>
}

extension Publisher {

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// This method creates the subscriber and immediately requests an unlimited number of values, prior to returning the subscriber.
    /// - parameter receiveValue: The closure to execute on receipt of a value. If `nil`, the sink uses an empty closure.
    /// - parameter receiveComplete: The closure to execute on completion. If `nil`, the sink uses an empty closure.
    /// - Returns: A subscriber that performs the provided closures upon receiving values or completion.
    public func sink(receiveCompletion: ((Subscribers.Completion<Self.Failure>) -> Void)? = nil, receiveValue: @escaping ((Self.Output) -> Void)) -> Subscribers.Sink<Self>
}

extension Publisher where Self.Output : Equatable {

    /// Publishes only elements that don’t match the previous element.
    ///
    /// - Returns: A publisher that consumes — rather than publishes — duplicate elements.
    public func removeDuplicates() -> Publishers.RemoveDuplicates<Self>
}

extension Publisher {

    public func removeDuplicates(by predicate: @escaping (Self.Output, Self.Output) -> Bool) -> Publishers.RemoveDuplicates<Self>

    public func tryRemoveDuplicates(by predicate: @escaping (Self.Output, Self.Output) throws -> Bool) -> Publishers.TryRemoveDuplicates<Self>
}

extension Publisher {

    /// Decodes the output from upstream using a specified `TopLevelDecoder`.
    /// For example, use `JSONDecoder`.
    public func decode<Item, Coder>(type: Item.Type, decoder: Coder) -> Publishers.Decode<Self, Item, Coder> where Item : Decodable, Coder : TopLevelDecoder, Self.Output == Coder.Input
}

extension Publisher where Self.Output : Encodable {

    /// Encodes the output from upstream using a specified `TopLevelEncoder`.
    /// For example, use `JSONEncoder`.
    public func encode<Coder>(encoder: Coder) -> Publishers.Encode<Self, Coder> where Coder : TopLevelEncoder
}

extension Publisher where Self.Output : Equatable {

    /// Publishes a Boolean value upon receiving an element equal to the argument.
    ///
    /// The contains publisher consumes all received elements until the upstream publisher produces a matching element. At that point, it emits `true` and finishes normally. If the upstream finishes normally without producing a matching element, this publisher emits `false`, then finishes.
    /// - Parameter output: An element to match against.
    /// - Returns: A publisher that emits the Boolean value `true` when the upstream publisher emits a matching value.
    public func contains(_ output: Self.Output) -> Publishers.Contains<Self>
}

extension Publisher {

    /// Subscribes to an additional publisher and invokes a closure upon receiving output from either publisher.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
    /// All upstream publishers need to finish for this publisher to finsh. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - other: Another publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this and another publisher.
    public func combineLatest<P, T>(_ other: P, _ transform: @escaping (Self.Output, P.Output) -> T) -> Publishers.CombineLatest<Self, P, T> where P : Publisher, Self.Failure == P.Failure

    /// Subscribes to two additional publishers and invokes a closure upon receiving output from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this publisher and two other publishers.
    public func combineLatest<P, Q, T>(_ publisher1: P, _ publisher2: Q, _ transform: @escaping (Self.Output, P.Output, Q.Output) -> T) -> Publishers.CombineLatest3<Self, P, Q, T> where P : Publisher, Q : Publisher, Self.Failure == P.Failure, P.Failure == Q.Failure

    /// Subscribes to three additional publishers and invokes a closure upon receiving output from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    ///   - publisher3: A fourth publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this publisher and three other publishers.
    public func combineLatest<P, Q, R, T>(_ publisher1: P, _ publisher2: Q, _ publisher3: R, _ transform: @escaping (Self.Output, P.Output, Q.Output, R.Output) -> T) -> Publishers.CombineLatest4<Self, P, Q, R, T> where P : Publisher, Q : Publisher, R : Publisher, Self.Failure == P.Failure, P.Failure == Q.Failure, Q.Failure == R.Failure

    /// Subscribes to an additional publisher and invokes an error-throwing closure upon receiving output from either publisher.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
    /// If the provided transform throws an error, the publisher fails with the error. `Self.Failure` and `P.Failure` must both be `Swift.Error`.
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - other: Another publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this and another publisher.
    public func tryCombineLatest<P, T>(_ other: P, _ transform: @escaping (Self.Output, P.Output) throws -> T) -> Publishers.TryCombineLatest<Self, P, T> where P : Publisher, P.Failure == Error

    /// Subscribes to two additional publishers and invokes an error-throwing closure upon receiving output from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
    /// If the provided transform throws an error, the publisher fails with the error. `Self.Failure`, `P.Failure`, and `Q.Failure` must all be `Swift.Error`.
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this publisher and two other publishers.
    public func tryCombineLatest<P, Q, T>(_ publisher1: P, _ publisher2: Q, _ transform: @escaping (Self.Output, P.Output, Q.Output) throws -> T) -> Publishers.TryCombineLatest3<Self, P, Q, T> where P : Publisher, Q : Publisher, P.Failure == Error, Q.Failure == Error

    /// Subscribes to three additional publishers and invokes an error-throwing closure upon receiving output from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
    /// If the provided transform throws an error, the publisher fails with the error. `Self.Failure`, `P.Failure`, `Q.Failure`, and `R.Failure` must all be `Swift.Error`.
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    ///   - publisher3: A fourth publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this publisher and three other publishers.
    public func tryCombineLatest<P, Q, R, T>(_ publisher1: P, _ publisher2: Q, _ publisher3: R, _ transform: @escaping (Self.Output, P.Output, Q.Output, R.Output) throws -> T) -> Publishers.TryCombineLatest4<Self, P, Q, R, T> where P : Publisher, Q : Publisher, R : Publisher, P.Failure == Error, Q.Failure == Error, R.Failure == Error
}

extension Publisher {

    /// Republishes elements up to the specified maximum count.
    ///
    /// - Parameter maxLength: The maximum number of elements to republish.
    /// - Returns: A publisher that publishes up to the specified number of elements before completing.
    public func prefix(_ maxLength: Int) -> Publishers.Output<Self>
}

extension Publisher {

    /// Prints log messages for all publishing events.
    ///
    /// - Parameter prefix: A string with which to prefix all log messages. Defaults to an empty string.
    /// - Returns: A publisher that prints log messages for all publishing events.
    public func print(_ prefix: String = "", to stream: TextOutputStream? = nil) -> Publishers.Print<Self>
}

extension Publisher {

    /// Republishes elements while a predicate closure indicates publishing should continue.
    ///
    /// The publisher finishes when the closure returns `false`.
    ///
    /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether publishing should continue.
    /// - Returns: A publisher that passes through elements until the predicate indicates publishing should finish.
    public func prefix(while predicate: @escaping (Self.Output) -> Bool) -> Publishers.PrefixWhile<Self>

    /// Republishes elements while a error-throwing predicate closure indicates publishing should continue.
    ///
    /// The publisher finishes when the closure returns `false`. If the closure throws, the publisher fails with the thrown error.
    ///
    /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether publishing should continue.
    /// - Returns: A publisher that passes through elements until the predicate throws or indicates publishing should finish.
    public func tryPrefix(while predicate: @escaping (Self.Output) throws -> Bool) -> Publishers.TryPrefixWhile<Self>
}

extension Publisher where Self.Failure == Never {

    /// Changes the failure type declared by the upstream publisher.
    ///
    /// The publisher returned by this method cannot actually fail with the specified type and instead just finishes normally. Instead, you use this method when you need to match the error types of two mismatched publishers.
    ///
    /// - Parameter failureType: The `Failure` type presented by this publisher.
    /// - Returns: A publisher that appears to send the specified failure type.
    public func setFailureType<E>(to failureType: E.Type) -> Publishers.SetFailureType<Self, E> where E : Error
}

extension Publisher {

    /// Publishes a Boolean value upon receiving an element that satisfies the predicate closure.
    ///
    /// This operator consumes elements produced from the upstream publisher until the upstream publisher produces a matching element.
    /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether the element satisfies the closure’s comparison logic.
    /// - Returns: A publisher that emits the Boolean value `true` when the upstream  publisher emits a matching value.
    public func contains(where predicate: @escaping (Self.Output) -> Bool) -> Publishers.ContainsWhere<Self>

    /// Publishes a Boolean value upon receiving an element that satisfies the throwing predicate closure.
    ///
    /// This operator consumes elements produced from the upstream publisher until the upstream publisher produces a matching element. If the closure throws, the stream fails with an error.
    /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether the element satisfies the closure’s comparison logic.
    /// - Returns: A publisher that emits the Boolean value `true` when the upstream publisher emits a matching value.
    public func tryContains(where predicate: @escaping (Self.Output) throws -> Bool) -> Publishers.TryContainsWhere<Self>
}

extension Publisher {

    /// Attaches the specified subscriber to this publisher.
    ///
    /// Always call this function instead of `receive(subscriber:)`.
    /// Adopters of `Publisher` must implement `receive(subscriber:)`. The implementation of `subscribe(_:)` in this extension calls through to `receive(subscriber:)`.
    /// - SeeAlso: `receive(subscriber:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`. After attaching, the subscriber can start to receive values.
    public func subscribe<S>(_ subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input
}

extension Publisher where Self.Failure == Never {

    /// Creates a connectable wrapper around the publisher.
    ///
    /// - Returns: A `ConnectablePublisher` wrapping this publisher.
    public func makeConnectable() -> Publishers.MakeConnectable<Self>
}

extension Publisher {

    /// Collects all received elements, and emits a single array of the collection when the upstream publisher finishes.
    ///
    /// If the upstream publisher fails with an error, this publisher forwards the error to the downstream receiver instead of sending its output.
    /// This publisher requests an unlimited number of elements from the upstream publisher. It only sends the collected array to its downstream after a request whose demand is greater than 0 items.
    /// Note: This publisher uses an unbounded amount of memory to store the received values.
    ///
    /// - Returns: A publisher that collects all received items and returns them as an array upon completion.
    public func collect() -> Publishers.Collect<Self>

    /// Collects up to the specified number of elements, and then emits a single array of the collection.
    ///
    /// If the upstream publisher finishes before filling the buffer, this publisher sends an array of all the items it has received. This may be fewer than `count` elements.
    /// If the upstream publisher fails with an error, this publisher forwards the error to the downstream receiver instead of sending its output.
    /// Note: When this publisher receives a request for `.max(n)` elements, it requests `.max(count * n)` from the upstream publisher.
    /// - Parameter count: The maximum number of received elements to buffer before publishing.
    /// - Returns: A publisher that collects up to the specified number of elements, and then publishes them as an array.
    public func collect(_ count: Int) -> Publishers.CollectByCount<Self>

    /// Collects elements by a given strategy, and emits a single array of the collection.
    ///
    /// If the upstream publisher finishes before filling the buffer, this publisher sends an array of all the items it has received. This may be fewer than `count` elements.
    /// If the upstream publisher fails with an error, this publisher forwards the error to the downstream receiver instead of sending its output.
    /// Note: When this publisher receives a request for `.max(n)` elements, it requests `.max(count * n)` from the upstream publisher.
    /// - Parameters:
    ///   - strategy: The strategy with which to collect and publish elements.
    ///   - options: `Scheduler` options to use for the strategy.
    /// - Returns: A publisher that collects elements by a given strategy, and emits a single array of the collection.
    public func collect<S>(_ strategy: Publishers.TimeGroupingStrategy<S>, options: S.SchedulerOptions? = nil) -> Publishers.CollectByTime<Self, S> where S : Scheduler
}

extension Publisher {

    /// Specifies the scheduler on which to receive elements from the publisher.
    ///
    /// You use the `receive(on:options:)` operator to receive results on a specific scheduler, such as performing UI work on the main run loop.
    /// In contrast with `subscribe(on:options:)`, which affects upstream messages, `receive(on:options:)` changes the execution context of downstream messages. In the following example, requests to `jsonPublisher` are performed on `backgroundQueue`, but elements received from it are performed on `RunLoop.main`.
    ///
    ///     let jsonPublisher = MyJSONLoaderPublisher() // Some publisher.
    ///     let labelUpdater = MyLabelUpdateSubscriber() // Some subscriber that updates the UI.
    ///
    ///     jsonPublisher
    ///         .subscribe(on: backgroundQueue)
    ///         .receiveOn(on: RunLoop.main)
    ///         .subscribe(labelUpdater)
    ///
    /// - Parameters:
    ///   - scheduler: The scheduler the publisher is to use for element delivery.
    ///   - options: Scheduler options that customize the element delivery.
    /// - Returns: A publisher that delivers elements using the specified scheduler.
    public func receive<S>(on scheduler: S, options: S.SchedulerOptions? = nil) -> Publishers.ReceiveOn<Self, S> where S : Scheduler
}

extension Publisher {

    /// Republishes elements until another publisher emits an element.
    ///
    /// After the second publisher publishes an element, the publisher returned by this method finishes.
    ///
    /// - Parameter publisher: A second publisher.
    /// - Returns: A publisher that republishes elements until the second publisher publishes an element.
    public func prefix<P>(untilOutputFrom publisher: P) -> Publishers.PrefixUntilOutput<Self, P> where P : Publisher
}

extension Publisher {

    public func subscribe<S>(_ subject: S) -> AnyCancellable where S : Subject, Self.Failure == S.Failure, Self.Output == S.Output
}

extension Publisher {

    /// Applies a closure that accumulates each element of a stream and publishes a final result upon completion.
    ///
    /// - Parameters:
    ///   - initialResult: The value the closure receives the first time it is called.
    ///   - nextPartialResult: A closure that takes the previously-accumulated value and the next element from the upstream publisher to produce a new value.
    /// - Returns: A publisher that applies the closure to all received elements and produces an accumulated value when the upstream publisher finishes.
    public func reduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Self.Output) -> T) -> Publishers.Reduce<Self, T>

    /// Applies an error-throwing closure that accumulates each element of a stream and publishes a final result upon completion.
    ///
    /// If the closure throws an error, the publisher fails, passing the error to its subscriber.
    /// - Parameters:
    ///   - initialResult: The value the closure receives the first time it is called.
    ///   - nextPartialResult: An error-throwing closure that takes the previously-accumulated value and the next element from the upstream publisher to produce a new value.
    /// - Returns: A publisher that applies the closure to all received elements and produces an accumulated value when the upstream publisher finishes.
    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Self.Output) throws -> T) -> Publishers.TryReduce<Self, T>
}

extension Publisher {

    /// Calls a closure with each received element and publishes any returned optional that has a value.
    ///
    /// - Parameter transform: A closure that receives a value and returns an optional value.
    /// - Returns: A publisher that republishes all non-`nil` results of calling the transform closure.
    public func compactMap<T>(_ transform: @escaping (Self.Output) -> T?) -> Publishers.CompactMap<Self, T>

    /// Calls an error-throwing closure with each received element and publishes any returned optional that has a value.
    ///
    /// If the closure throws an error, the publisher cancels the upstream and sends the thrown error to the downstream receiver as a `Failure`.
    /// - Parameter transform: an error-throwing closure that receives a value and returns an optional value.
    /// - Returns: A publisher that republishes all non-`nil` results of calling the transform closure.
    public func tryCompactMap<T>(_ transform: @escaping (Self.Output) throws -> T?) -> Publishers.TryCompactMap<Self, T>
}

extension Publisher {

    /// Combines elements from this publisher with those from another publisher, delivering an interleaved sequence of elements.
    ///
    /// The merged publisher continues to emit elements until all upstream publishers finish. If an upstream publisher produces an error, the merged publisher fails with that error.
    /// - Parameter other: Another publisher.
    /// - Returns: A publisher that emits an event when either upstream publisher emits an event.
    public func merge<P>(with other: P) -> Publishers.Merge<Self, P> where P : Publisher, Self.Failure == P.Failure, Self.Output == P.Output

    /// Combines elements from this publisher with those from two other publishers, delivering an interleaved sequence of elements.
    ///
    /// The merged publisher continues to emit elements until all upstream publishers finish. If an upstream publisher produces an error, the merged publisher fails with that error.
    ///
    /// - Parameters:
    ///   - b: A second publisher.
    ///   - c: A third publisher.
    /// - Returns:  A publisher that emits an event when any upstream publisher emits
    /// an event.
    public func merge<B, C>(with b: B, _ c: C) -> Publishers.Merge3<Self, B, C> where B : Publisher, C : Publisher, Self.Failure == B.Failure, Self.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output

    /// Combines elements from this publisher with those from three other publishers, delivering
    /// an interleaved sequence of elements.
    ///
    /// The merged publisher continues to emit elements until all upstream publishers finish. If an upstream publisher produces an error, the merged publisher fails with that error.
    ///
    /// - Parameters:
    ///   - b: A second publisher.
    ///   - c: A third publisher.
    ///   - d: A fourth publisher.
    /// - Returns: A publisher that emits an event when any upstream publisher emits an event.
    public func merge<B, C, D>(with b: B, _ c: C, _ d: D) -> Publishers.Merge4<Self, B, C, D> where B : Publisher, C : Publisher, D : Publisher, Self.Failure == B.Failure, Self.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output, C.Failure == D.Failure, C.Output == D.Output

    /// Combines elements from this publisher with those from four other publishers, delivering an interleaved sequence of elements.
    ///
    /// The merged publisher continues to emit elements until all upstream publishers finish. If an upstream publisher produces an error, the merged publisher fails with that error.
    ///
    /// - Parameters:
    ///   - b: A second publisher.
    ///   - c: A third publisher.
    ///   - d: A fourth publisher.
    ///   - e: A fifth publisher.
    /// - Returns: A publisher that emits an event when any upstream publisher emits an event.
    public func merge<B, C, D, E>(with b: B, _ c: C, _ d: D, _ e: E) -> Publishers.Merge5<Self, B, C, D, E> where B : Publisher, C : Publisher, D : Publisher, E : Publisher, Self.Failure == B.Failure, Self.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output, C.Failure == D.Failure, C.Output == D.Output, D.Failure == E.Failure, D.Output == E.Output

    /// Combines elements from this publisher with those from five other publishers, delivering an interleaved sequence of elements.
    ///
    /// The merged publisher continues to emit elements until all upstream publishers finish. If an upstream publisher produces an error, the merged publisher fails with that error.
    ///
    /// - Parameters:
    ///   - b: A second publisher.
    ///   - c: A third publisher.
    ///   - d: A fourth publisher.
    ///   - e: A fifth publisher.
    ///   - f: A sixth publisher.
    /// - Returns: A publisher that emits an event when any upstream publisher emits an event.
    public func merge<B, C, D, E, F>(with b: B, _ c: C, _ d: D, _ e: E, _ f: F) -> Publishers.Merge6<Self, B, C, D, E, F> where B : Publisher, C : Publisher, D : Publisher, E : Publisher, F : Publisher, Self.Failure == B.Failure, Self.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output, C.Failure == D.Failure, C.Output == D.Output, D.Failure == E.Failure, D.Output == E.Output, E.Failure == F.Failure, E.Output == F.Output

    /// Combines elements from this publisher with those from six other publishers, delivering an interleaved sequence of elements.
    ///
    /// The merged publisher continues to emit elements until all upstream publishers finish. If an upstream publisher produces an error, the merged publisher fails with that error.
    ///
    /// - Parameters:
    ///   - b: A second publisher.
    ///   - c: A third publisher.
    ///   - d: A fourth publisher.
    ///   - e: A fifth publisher.
    ///   - f: A sixth publisher.
    ///   - g: A seventh publisher.
    /// - Returns: A publisher that emits an event when any upstream publisher emits an event.
    public func merge<B, C, D, E, F, G>(with b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G) -> Publishers.Merge7<Self, B, C, D, E, F, G> where B : Publisher, C : Publisher, D : Publisher, E : Publisher, F : Publisher, G : Publisher, Self.Failure == B.Failure, Self.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output, C.Failure == D.Failure, C.Output == D.Output, D.Failure == E.Failure, D.Output == E.Output, E.Failure == F.Failure, E.Output == F.Output, F.Failure == G.Failure, F.Output == G.Output

    /// Combines elements from this publisher with those from seven other publishers, delivering an interleaved sequence of elements.
    ///
    /// The merged publisher continues to emit elements until all upstream publishers finish. If an upstream publisher produces an error, the merged publisher fails with that error.
    ///
    /// - Parameters:
    ///   - b: A second publisher.
    ///   - c: A third publisher.
    ///   - d: A fourth publisher.
    ///   - e: A fifth publisher.
    ///   - f: A sixth publisher.
    ///   - g: A seventh publisher.
    ///   - h: An eighth publisher.
    /// - Returns: A publisher that emits an event when any upstream publisher emits an event.
    public func merge<B, C, D, E, F, G, H>(with b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H) -> Publishers.Merge8<Self, B, C, D, E, F, G, H> where B : Publisher, C : Publisher, D : Publisher, E : Publisher, F : Publisher, G : Publisher, H : Publisher, Self.Failure == B.Failure, Self.Output == B.Output, B.Failure == C.Failure, B.Output == C.Output, C.Failure == D.Failure, C.Output == D.Output, D.Failure == E.Failure, D.Output == E.Output, E.Failure == F.Failure, E.Output == F.Output, F.Failure == G.Failure, F.Output == G.Output, G.Failure == H.Failure, G.Output == H.Output

    /// Combines elements from this publisher with those from another publisher of the same type, delivering an interleaved sequence of elements.
    ///
    /// - Parameter other: Another publisher of this publisher's type.
    /// - Returns: A publisher that emits an event when either upstream publisher emits
    /// an event.
    public func merge(with other: Self) -> Publishers.MergeMany<Self>
}

extension Publisher {

    /// Transforms elements from the upstream publisher by providing the current element to a closure along with the last value returned by the closure.
    ///
    ///     let pub = (0...5)
    ///         .publisher()
    ///         .scan(0, { return $0 + $1 })
    ///         .sink(receiveValue: { print ("\($0)", terminator: " ") })
    ///      // Prints "0 1 3 6 10 15 ".
    ///
    ///
    /// - Parameters:
    ///   - initialResult: The previous result returned by the `nextPartialResult` closure.
    ///   - nextPartialResult: A closure that takes as its arguments the previous value returned by the closure and the next element emitted from the upstream publisher.
    /// - Returns: A publisher that transforms elements by applying a closure that receives its previous return value and the next element from the upstream publisher.
    public func scan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Self.Output) -> T) -> Publishers.Scan<Self, T>

    /// Transforms elements from the upstream publisher by providing the current element to an error-throwing closure along with the last value returned by the closure.
    ///
    /// If the closure throws an error, the publisher fails with the error.
    /// - Parameters:
    ///   - initialResult: The previous result returned by the `nextPartialResult` closure.
    ///   - nextPartialResult: An error-throwing closure that takes as its arguments the previous value returned by the closure and the next element emitted from the upstream publisher.
    /// - Returns: A publisher that transforms elements by applying a closure that receives its previous return value and the next element from the upstream publisher.
    public func tryScan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Self.Output) throws -> T) -> Publishers.TryScan<Self, T>
}

extension Publisher {

    /// Publishes the number of elements received from the upstream publisher.
    ///
    /// - Returns: A publisher that consumes all elements until the upstream publisher finishes, then emits a single
    /// value with the total number of elements received.
    public func count() -> Publishers.Count<Self>
}

extension Publisher {

    /// Only publishes the last element of a stream that satisfies a predicate closure, after the stream finishes.
    /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether to publish the element.
    /// - Returns: A publisher that only publishes the last element satisfying the given predicate.
    public func last(where predicate: @escaping (Self.Output) -> Bool) -> Publishers.LastWhere<Self>

    /// Only publishes the last element of a stream that satisfies a error-throwing predicate closure, after the stream finishes.
    ///
    /// If the predicate closure throws, the publisher fails with the thrown error.
    /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether to publish the element.
    /// - Returns: A publisher that only publishes the last element satisfying the given predicate.
    public func tryLast(where predicate: @escaping (Self.Output) throws -> Bool) -> Publishers.TryLastWhere<Self>
}

extension Publisher {

    /// Ingores all upstream elements, but passes along a completion state (finished or failed).
    ///
    /// The output type of this publisher is `Never`.
    /// - Returns: A publisher that ignores all upstream elements.
    public func ignoreOutput() -> Publishers.IgnoreOutput<Self>
}

extension Publisher where Self.Failure == Self.Output.Failure, Self.Output : Publisher {

    /// Flattens the stream of events from multiple upstream publishers to appear as if they were coming from a single stream of events.
    ///
    /// This operator switches the inner publisher as new ones arrive but keeps the outer one constant for downstream subscribers.
    /// For example, given the type `Publisher<Publisher<Data, NSError>, Never>`, calling `switchToLatest()` will result in the type `Publisher<Data, NSError>`. The downstream subscriber sees a continuous stream of values even though they may be coming from different upstream publishers.
    public func switchToLatest() -> Publishers.SwitchToLatest<Self.Output, Self>
}

extension Publisher {

    /// Attempts to recreate a failed subscription with the upstream publisher using a specified number of attempts to establish the connection.
    ///
    /// After exceeding the specified number of retries, the publisher passes the failure to the downstream receiver.
    /// - Parameter retries: The number of times to attempt to recreate the subscription.
    /// - Returns: A publisher that attempts to recreate its subscription to a failed upstream publisher.
    public func retry(_ retries: Int) -> Publishers.Retry<Self>

    /// Performs an unlimited number of attempts to recreate the subscription to the upstream publisher if it fails.
    ///
    /// - Returns: A publisher that attempts to recreate its subscription to a failed upstream publisher.
    public func retry() -> Publishers.Retry<Self>
}

extension Publisher {

    /// Publishes either the most-recent or first element published by the upstream publisher in the specified time interval.
    ///
    /// - Parameters:
    ///   - interval: The interval at which to find and emit the most recent element, expressed in the time system of the scheduler.
    ///   - scheduler: The scheduler on which to publish elements.
    ///   - latest: A Boolean value that indicates whether to publish the most recent element. If `false`, the publisher emits the first element received during the interval.
    /// - Returns: A publisher that emits either the most-recent or first element received during the specified interval.
    public func throttle<S>(for interval: S.SchedulerTimeType.Stride, scheduler: S, latest: Bool) -> Publishers.Throttle<Self, S> where S : Scheduler
}

extension Publisher {

    /// Returns a publisher as a class instance.
    ///
    /// The downstream subscriber receieves elements and completion states unchanged from the upstream publisher. Use this operator when you want to use reference semantics, such as storing a publisher instance in a property.
    ///
    /// - Returns: A class instance that republishes its upstream publisher.
    public func share() -> Publishers.Share<Self>
}

extension Publisher where Self.Output : Comparable {

    /// Publishes the minimum value received from the upstream publisher, after it finishes.
    ///
    /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
    /// - Returns: A publisher that publishes the minimum value received from the upstream publisher, after the upstream publisher finishes.
    public func min() -> Publishers.Comparison<Self>

    /// Publishes the maximum value received from the upstream publisher, after it finishes.
    ///
    /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
    /// - Returns: A publisher that publishes the maximum value received from the upstream publisher, after the upstream publisher finishes.
    public func max() -> Publishers.Comparison<Self>
}

extension Publisher {

    /// Publishes the minimum value received from the upstream publisher, after it finishes.
    ///
    /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
    /// - Parameter areInIncreasingOrder: A closure that receives two elements and returns `true` if they are in increasing order.
    /// - Returns: A publisher that publishes the minimum value received from the upstream publisher, after the upstream publisher finishes.
    public func min(by areInIncreasingOrder: @escaping (Self.Output, Self.Output) -> Bool) -> Publishers.Comparison<Self>

    /// Publishes the minimum value received from the upstream publisher, using the provided error-throwing closure to order the items.
    ///
    /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
    /// - Parameter areInIncreasingOrder: A throwing closure that receives two elements and returns `true` if they are in increasing order. If this closure throws, the publisher terminates with a `Failure`.
    /// - Returns: A publisher that publishes the minimum value received from the upstream publisher, after the upstream publisher finishes.
    public func tryMin(by areInIncreasingOrder: @escaping (Self.Output, Self.Output) throws -> Bool) -> Publishers.TryComparison<Self>

    /// Publishes the maximum value received from the upstream publisher, using the provided ordering closure.
    ///
    /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
    /// - Parameter areInIncreasingOrder: A closure that receives two elements and returns `true` if they are in increasing order.
    /// - Returns: A publisher that publishes the maximum value received from the upstream publisher, after the upstream publisher finishes.
    public func max(by areInIncreasingOrder: @escaping (Self.Output, Self.Output) -> Bool) -> Publishers.Comparison<Self>

    /// Publishes the maximum value received from the upstream publisher, using the provided error-throwing closure to order the items.
    ///
    /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
    /// - Parameter areInIncreasingOrder: A throwing closure that receives two elements and returns `true` if they are in increasing order. If this closure throws, the publisher terminates with a `Failure`.
    /// - Returns: A publisher that publishes the maximum value received from the upstream publisher, after the upstream publisher finishes.
    public func tryMax(by areInIncreasingOrder: @escaping (Self.Output, Self.Output) throws -> Bool) -> Publishers.TryComparison<Self>
}

extension Publisher {

    /// Replaces nil elements in the stream with the proviced element.
    ///
    /// - Parameter output: The element to use when replacing `nil`.
    /// - Returns: A publisher that replaces `nil` elements from the upstream publisher with the provided element.
    public func replaceNil<T>(with output: T) -> Publishers.Map<Self, T> where Self.Output == T?
}

extension Publisher {

    /// Replaces any errors in the stream with the provided element.
    ///
    /// If the upstream publisher fails with an error, this publisher emits the provided element, then finishes normally.
    /// - Parameter output: An element to emit when the upstream publisher fails.
    /// - Returns: A publisher that replaces an error from the upstream publisher with the provided output element.
    public func replaceError(with output: Self.Output) -> Publishers.ReplaceError<Self>

    /// Replaces an empty stream with the provided element.
    ///
    /// If the upstream publisher finishes without producing any elements, this publisher emits the provided element, then finishes normally.
    /// - Parameter output: An element to emit when the upstream publisher finishes without emitting any elements.
    /// - Returns: A publisher that replaces an empty stream with the provided output element.
    public func replaceEmpty(with output: Self.Output) -> Publishers.ReplaceEmpty<Self>
}

extension Publisher {

    /// Raises a fatal error when its upstream publisher fails, and otherwise republishes all received input.
    ///
    /// Use this function for internal sanity checks that are active during testing but do not impact performance of shipping code.
    ///
    /// - Parameters:
    ///   - prefix: A string used at the beginning of the fatal error message.
    ///   - file: A filename used in the error message. This defaults to `#file`.
    ///   - line: A line number used in the error message. This defaults to `#line`.
    /// - Returns: A publisher that raises a fatal error when its upstream publisher fails.
    public func assertNoFailure(_ prefix: String = "", file: StaticString = #file, line: UInt = #line) -> Publishers.AssertNoFailure<Self>
}

extension Publisher {

    /// Ignores elements from the upstream publisher until it receives an element from a second publisher.
    ///
    /// This publisher requests a single value from the upstream publisher, and it ignores (drops) all elements from that publisher until the upstream publisher produces a value. After the `other` publisher produces an element, this publisher cancels its subscription to the `other` publisher, and allows events from the `upstream` publisher to pass through.
    /// After this publisher receives a subscription from the upstream publisher, it passes through backpressure requests from downstream to the upstream publisher. If the upstream publisher acts on those requests before the other publisher produces an item, this publisher drops the elements it receives from the upstream publisher.
    ///
    /// - Parameter publisher: A publisher to monitor for its first emitted element.
    /// - Returns: A publisher that drops elements from the upstream publisher until the `other` publisher produces a value.
    public func drop<P>(untilOutputFrom publisher: P) -> Publishers.DropUntilOutput<Self, P> where P : Publisher, Self.Failure == P.Failure
}

extension Publisher {

    /// Performs the specified closures when publisher events occur.
    ///
    /// - Parameters:
    ///   - receiveSubscription: A closure that executes when the publisher receives the  subscription from the upstream publisher. Defaults to `nil`.
    ///   - receiveOutput: A closure that executes when the publisher receives a value from the upstream publisher. Defaults to `nil`.
    ///   - receiveCompletion: A closure that executes when the publisher receives the completion from the upstream publisher. Defaults to `nil`.
    ///   - receiveCancel: A closure that executes when the downstream receiver cancels publishing. Defaults to `nil`.
    ///   - receiveRequest: A closure that executes when the publisher receives a request for more elements. Defaults to `nil`.
    /// - Returns: A publisher that performs the specified closures when publisher events occur.
    public func handleEvents(receiveSubscription: ((Subscription) -> Void)? = nil, receiveOutput: ((Self.Output) -> Void)? = nil, receiveCompletion: ((Subscribers.Completion<Self.Failure>) -> Void)? = nil, receiveCancel: (() -> Void)? = nil, receiveRequest: ((Subscribers.Demand) -> Void)? = nil) -> Publishers.HandleEvents<Self>
}

extension Publisher {

    /// Prefixes a `Publisher`'s output with the specified sequence.
    /// - Parameter elements: The elements to publish before this publisher’s elements.
    /// - Returns: A publisher that prefixes the specified elements prior to this publisher’s elements.
    public func prepend(_ elements: Self.Output...) -> Publishers.Concatenate<Publishers.Sequence<[Self.Output], Self.Failure>, Self>

    /// Prefixes a `Publisher`'s output with the specified sequence.
    /// - Parameter elements: A sequence of elements to publish before this publisher’s elements.
    /// - Returns: A publisher that prefixes the sequence of elements prior to this publisher’s elements.
    public func prepend<S>(_ elements: S) -> Publishers.Concatenate<Publishers.Sequence<S, Self.Failure>, Self> where S : Sequence, Self.Output == S.Element

    /// Prefixes this publisher’s output with the elements emitted by the given publisher.
    ///
    /// The resulting publisher doesn’t emit any elements until the prefixing publisher finishes.
    /// - Parameter publisher: The prefixing publisher.
    /// - Returns: A publisher that prefixes the prefixing publisher’s elements prior to this publisher’s elements.
    public func prepend<P>(_ publisher: P) -> Publishers.Concatenate<P, Self> where P : Publisher, Self.Failure == P.Failure, Self.Output == P.Output

    /// Append a `Publisher`'s output with the specified sequence.
    public func append(_ elements: Self.Output...) -> Publishers.Concatenate<Self, Publishers.Sequence<[Self.Output], Self.Failure>>

    /// Appends a `Publisher`'s output with the specified sequence.
    public func append<S>(_ elements: S) -> Publishers.Concatenate<Self, Publishers.Sequence<S, Self.Failure>> where S : Sequence, Self.Output == S.Element

    /// Appends this publisher’s output with the elements emitted by the given publisher.
    ///
    /// This operator produces no elements until this publisher finishes. It then produces this publisher’s elements, followed by the given publisher’s elements. If this publisher fails with an error, the prefixing publisher does not publish the provided publisher’s elements.
    /// - Parameter publisher: The appending publisher.
    /// - Returns: A publisher that appends the appending publisher’s elements after this publisher’s elements.
    public func append<P>(_ publisher: P) -> Publishers.Concatenate<Self, P> where P : Publisher, Self.Failure == P.Failure, Self.Output == P.Output
}

extension Publisher {

    /// Publishes elements only after a specified time interval elapses between events.
    ///
    /// Use this operator when you want to wait for a pause in the delivery of events from the upstream publisher. For example, call `debounce` on the publisher from a text field to only receive elements when the user pauses or stops typing. When they start typing again, the `debounce` holds event delivery until the next pause.
    /// - Parameters:
    ///   - dueTime: The time the publisher should wait before publishing an element.
    ///   - scheduler: The scheduler on which this publisher delivers elements
    ///   - options: Scheduler options that customize this publisher’s delivery of elements.
    /// - Returns: A publisher that publishes events only after a specified time elapses.
    public func debounce<S>(for dueTime: S.SchedulerTimeType.Stride, scheduler: S, options: S.SchedulerOptions? = nil) -> Publishers.Debounce<Self, S> where S : Scheduler
}

extension Publisher {

    /// Only publishes the last element of a stream, after the stream finishes.
    /// - Returns: A publisher that only publishes the last element of a stream.
    public func last() -> Publishers.Last<Self>
}

extension Publisher {

    /// Terminates publishing if the upstream publisher exceeds the specified time interval without producing an element.
    ///
    /// - Parameters:
    ///   - interval: The maximum time interval the publisher can go without emitting an element, expressed in the time system of the scheduler.
    ///   - scheduler: The scheduler to deliver events on.
    ///   - options: Scheduler options that customize the delivery of elements.
    ///   - customError: A closure that executes if the publisher times out. The publisher sends the failure returned by this closure to the subscriber as the reason for termination.
    /// - Returns: A publisher that terminates if the specified interval elapses with no events received from the upstream publisher.
    public func timeout<S>(_ interval: S.SchedulerTimeType.Stride, scheduler: S, options: S.SchedulerOptions? = nil, customError: (() -> Self.Failure)? = nil) -> Publishers.Timeout<Self, S> where S : Scheduler
}

extension Publisher {

    public func buffer(size: Int, prefetch: Publishers.PrefetchStrategy, whenFull: Publishers.BufferingStrategy<Self.Failure>) -> Publishers.Buffer<Self>
}

extension Publisher {

    /// Combine elements from another publisher and deliver pairs of elements as tuples.
    ///
    /// The returned publisher waits until both publishers have emitted an event, then delivers the oldest unconsumed event from each publisher together as a tuple to the subscriber.
    /// For example, if publisher `P1` emits elements `a` and `b`, and publisher `P2` emits event `c`, the zip publisher emits the tuple `(a, c)`. It won’t emit a tuple with event `b` until `P2` emits another event.
    /// If either upstream publisher finishes successfuly or fails with an error, the zipped publisher does the same.
    ///
    /// - Parameter other: Another publisher.
    /// - Returns: A publisher that emits pairs of elements from the upstream publishers as tuples.
    public func zip<P>(_ other: P) -> Publishers.Zip<Self, P> where P : Publisher, Self.Failure == P.Failure

    /// Combine elements from two other publishers and deliver groups of elements as tuples.
    ///
    /// The returned publisher waits until all three publishers have emitted an event, then delivers the oldest unconsumed event from each publisher as a tuple to the subscriber.
    /// For example, if publisher `P1` emits elements `a` and `b`, and publisher `P2` emits elements `c` and `d`, and publisher `P3` emits the event `e`, the zip publisher emits the tuple `(a, c, e)`. It won’t emit a tuple with elements `b` or `d` until `P3` emits another event.
    /// If any upstream publisher finishes successfuly or fails with an error, the zipped publisher does the same.
    ///
    /// - Parameters:
    ///   - publisher1: A second publisher.
    ///   - publisher2: A third publisher.
    /// - Returns: A publisher that emits groups of elements from the upstream publishers as tuples.
    public func zip<P, Q>(_ publisher1: P, _ publisher2: Q) -> Publishers.Zip3<Self, P, Q> where P : Publisher, Q : Publisher, Self.Failure == P.Failure, P.Failure == Q.Failure

    /// Combine elements from three other publishers and deliver groups of elements as tuples.
    ///
    /// The returned publisher waits until all four publishers have emitted an event, then delivers the oldest unconsumed event from each publisher as a tuple to the subscriber.
    /// For example, if publisher `P1` emits elements `a` and `b`, and publisher `P2` emits elements `c` and `d`, and publisher `P3` emits the elements `e` and `f`, and publisher `P4` emits the event `g`, the zip publisher emits the tuple `(a, c, e, g)`. It won’t emit a tuple with elements `b`, `d`, or `f` until `P4` emits another event.
    /// If any upstream publisher finishes successfuly or fails with an error, the zipped publisher does the same.
    ///
    /// - Parameters:
    ///   - publisher1: A second publisher.
    ///   - publisher2: A third publisher.
    ///   - publisher3: A fourth publisher.
    /// - Returns: A publisher that emits groups of elements from the upstream publishers as tuples.
    public func zip<P, Q, R>(_ publisher1: P, _ publisher2: Q, _ publisher3: R) -> Publishers.Zip4<Self, P, Q, R> where P : Publisher, Q : Publisher, R : Publisher, Self.Failure == P.Failure, P.Failure == Q.Failure, Q.Failure == R.Failure
}

extension Publisher {

    /// Publishes a specific element, indicated by its index in the sequence of published elements.
    ///
    /// If the publisher completes normally or with an error before publishing the specified element, then the publisher doesn’t produce any elements.
    /// - Parameter index: The index that indicates the element to publish.
    /// - Returns: A publisher that publishes a specific indexed element.
    public func output(at index: Int) -> Publishers.Output<Self>

    /// Publishes elements specified by their range in the sequence of published elements.
    ///
    /// After all elements are published, the publisher finishes normally.
    /// If the publisher completes normally or with an error before producing all the elements in the range, it doesn’t publish the remaining elements.
    /// - Parameter range: A range that indicates which elements to publish.
    /// - Returns: A publisher that publishes elements specified by a range.
    public func output<R>(in range: R) -> Publishers.Output<Self> where R : RangeExpression, R.Bound == Int
}

extension Publisher {

    /// Handles errors from an upstream publisher by replacing it with another publisher.
    ///
    /// The following example replaces any error from the upstream publisher and replaces the upstream with a `Just` publisher. This continues the stream by publishing a single value and completing normally.
    /// ```
    /// enum SimpleError: Error { case error }
    /// let errorPublisher = (0..<10).publisher().tryMap { v -> Int in
    ///     if v < 5 {
    ///         return v
    ///     } else {
    ///         throw SimpleError.error
    ///     }
    /// }
    ///
    /// let noErrorPublisher = errorPublisher.catch { _ in
    ///     return Publishers.Just(100)
    /// }
    /// ```
    /// Backpressure note: This publisher passes through `request` and `cancel` to the upstream. After receiving an error, the publisher sends sends any unfulfilled demand to the new `Publisher`.
    /// - Parameter handler: A closure that accepts the upstream failure as input and returns a publisher to replace the upstream publisher.
    /// - Returns: A publisher that handles errors from an upstream publisher by replacing the failed publisher with another publisher.
    public func `catch`<P>(_ handler: @escaping (Self.Failure) -> P) -> Publishers.Catch<Self, P> where P : Publisher, Self.Output == P.Output
}

extension Publisher {

    /// Delays delivery of all output to the downstream receiver by a specified amount of time on a particular scheduler.
    ///
    /// The delay affects the delivery of elements and completion, but not of the original subscription.
    /// - Parameters:
    ///   - interval: The amount of time to delay.
    ///   - tolerance: The allowed tolerance in firing delayed events.
    ///   - scheduler: The scheduler to deliver the delayed events.
    ///   - options: Options relevant to the scheduler’s behavior.
    /// - Returns: A publisher that delays delivery of elements and completion to the downstream receiver.
    public func delay<S>(for interval: S.SchedulerTimeType.Stride, tolerance: S.SchedulerTimeType.Stride? = nil, scheduler: S, options: S.SchedulerOptions? = nil) -> Publishers.Delay<Self, S> where S : Scheduler
}

extension Publisher {

    /// Omits the specified number of elements before republishing subsequent elements.
    ///
    /// - Parameter count: The number of elements to omit.
    /// - Returns: A publisher that does not republish the first `count` elements.
    public func dropFirst(_ count: Int = 1) -> Publishers.Drop<Self>
}

extension Publisher {

    public func eraseToAnyPublisher() -> AnyPublisher<Self.Output, Self.Failure>
}

extension Publisher {

    /// Publishes the first element of a stream, then finishes.
    ///
    /// If this publisher doesn’t receive any elements, it finishes without publishing.
    /// - Returns: A publisher that only publishes the first element of a stream.
    public func first() -> Publishers.First<Self>

    /// Publishes the first element of a stream to satisfy a predicate closure, then finishes.
    ///
    /// The publisher ignores all elements after the first. If this publisher doesn’t receive any elements, it finishes without publishing.
    /// - Parameter predicate: A closure that takes an element as a parameter and returns a Boolean value that indicates whether to publish the element.
    /// - Returns: A publisher that only publishes the first element of a stream that satifies the predicate.
    public func first(where predicate: @escaping (Self.Output) -> Bool) -> Publishers.FirstWhere<Self>

    /// Publishes the first element of a stream to satisfy a throwing predicate closure, then finishes.
    ///
    /// The publisher ignores all elements after the first. If this publisher doesn’t receive any elements, it finishes without publishing. If the predicate closure throws, the publisher fails with an error.
    /// - Parameter predicate: A closure that takes an element as a parameter and returns a Boolean value that indicates whether to publish the element.
    /// - Returns: A publisher that only publishes the first element of a stream that satifies the predicate.
    public func tryFirst(where predicate: @escaping (Self.Output) throws -> Bool) -> Publishers.TryFirstWhere<Self>
}

/// A namespace for types related to the Publisher protocol.
///
/// The various operators defined as extensions on `Publisher` implement their functionality as classes or structures that extend this enumeration. For example, the `contains()` operator returns a `Publishers.Contains` instance.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public enum Publishers {
}

extension Publishers {

    final public class Multicast<Upstream, SubjectType> : ConnectablePublisher where Upstream : Publisher, SubjectType : Subject, Upstream.Failure == SubjectType.Failure, Upstream.Output == SubjectType.Output {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        final public func receive<S>(subscriber: S) where S : Subscriber, SubjectType.Failure == S.Failure, SubjectType.Output == S.Input

        /// Connects to the publisher and returns a `Cancellable` instance with which to cancel publishing.
        ///
        /// - Returns: A `Cancellable` instance that can be used to cancel publishing.
        final public func connect() -> Cancellable
    }
}

extension Publishers {

    /// A publisher that measures and emits the time interval between events received from an upstream publisher.
    public struct MeasureInterval<Upstream, Context> : Publisher where Upstream : Publisher, Context : Scheduler {

        /// The kind of values published by this publisher.
        public typealias Output = Context.SchedulerTimeType.Stride

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The scheduler on which to deliver elements.
        public let scheduler: Context

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, S.Input == Context.SchedulerTimeType.Stride
    }
}

extension Publishers {

    /// A publisher that omits elements from an upstream publisher until a given closure returns false.
    public struct DropWhile<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The closure that indicates whether to drop the element.
        public let predicate: (Upstream.Output) -> Bool

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }

    /// A publisher that omits elements from an upstream publisher until a given error-throwing closure returns false.
    public struct TryDropWhile<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The error-throwing closure that indicates whether to drop the element.
        public let predicate: (Upstream.Output) throws -> Bool

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Output == S.Input, S.Failure == Publishers.TryDropWhile<Upstream>.Failure
    }
}

extension Publishers {

    /// A publisher that republishes all elements that match a provided closure.
    public struct Filter<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// A closure that indicates whether to republish an element.
        public let isIncluded: (Upstream.Output) -> Bool

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }

    /// A publisher that republishes all elements that match a provided error-throwing closure.
    public struct TryFilter<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// A error-throwing closure that indicates whether to republish an element.
        public let isIncluded: (Upstream.Output) throws -> Bool

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Output == S.Input, S.Failure == Publishers.TryFilter<Upstream>.Failure
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
        public init(upstream: Upstream, receiveSubscription: ((Subscription) -> Bool)? = nil, receiveOutput: ((Upstream.Output) -> Bool)? = nil, receiveCompletion: ((Subscribers.Completion<Publishers.Breakpoint<Upstream>.Failure>) -> Bool)? = nil)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }
}

extension Publishers {

    /// A publisher that awaits subscription before running the supplied closure to create a publisher for the new subscriber.
    public struct Deferred<DeferredPublisher> : Publisher where DeferredPublisher : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = DeferredPublisher.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = DeferredPublisher.Failure

        /// The closure to execute when it receives a subscription.
        ///
        /// The publisher returned by this closure immediately receives the incoming subscription.
        public let createPublisher: () -> DeferredPublisher

        /// Creates a deferred publisher.
        ///
        /// - Parameter createPublisher: The closure to execute when calling `subscribe(_:)`.
        public init(createPublisher: @escaping () -> DeferredPublisher)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, DeferredPublisher.Failure == S.Failure, DeferredPublisher.Output == S.Input
    }
}

extension Publishers {

    /// A publisher that publishes a single Boolean value that indicates whether all received elements pass a given predicate.
    public struct AllSatisfy<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Bool

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// A closure that evaluates each received element.
        ///
        ///  Return `true` to continue, or `false` to cancel the upstream and finish.
        public let predicate: (Upstream.Output) -> Bool

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, S.Input == Publishers.AllSatisfy<Upstream>.Output
    }

    /// A publisher that publishes a single Boolean value that indicates whether all received elements pass a given error-throwing predicate.
    public struct TryAllSatisfy<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Bool

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// A closure that evaluates each received element.
        ///
        /// Return `true` to continue, or `false` to cancel the upstream and complete. The closure may throw, in which case the publisher cancels the upstream publisher and fails with the thrown error.
        public let predicate: (Upstream.Output) throws -> Bool

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Publishers.TryAllSatisfy<Upstream>.Failure, S.Input == Publishers.TryAllSatisfy<Upstream>.Output
    }
}

extension Publishers {

    public struct RemoveDuplicates<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        public let upstream: Upstream

        public let predicate: (Upstream.Output, Upstream.Output) -> Bool

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }

    public struct TryRemoveDuplicates<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error

        public let upstream: Upstream

        public let predicate: (Upstream.Output, Upstream.Output) throws -> Bool

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Output == S.Input, S.Failure == Publishers.TryRemoveDuplicates<Upstream>.Failure
    }
}

extension Publishers {

    public struct Decode<Upstream, Output, Coder> : Publisher where Upstream : Publisher, Output : Decodable, Coder : TopLevelDecoder, Upstream.Output == Coder.Input {

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error

        public let upstream: Upstream

        public init(upstream: Upstream, decoder: Coder)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, S.Failure == Publishers.Decode<Upstream, Output, Coder>.Failure
    }

    public struct Encode<Upstream, Coder> : Publisher where Upstream : Publisher, Coder : TopLevelEncoder, Upstream.Output : Encodable {

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error

        /// The kind of values published by this publisher.
        public typealias Output = Coder.Output

        public let upstream: Upstream

        public init(upstream: Upstream, encoder: Coder)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Coder.Output == S.Input, S.Failure == Publishers.Encode<Upstream, Coder>.Failure
    }
}


extension Publishers {

    /// A publisher that emits a Boolean value when a specified element is received from its upstream publisher.
    public struct Contains<Upstream> : Publisher where Upstream : Publisher, Upstream.Output : Equatable {

        /// The kind of values published by this publisher.
        public typealias Output = Bool

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The element to scan for in the upstream publisher.
        public let output: Upstream.Output

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, S.Input == Publishers.Contains<Upstream>.Output
    }
}

extension Publishers {

    /// A publisher that receives and combines the latest elements from two publishers.
    public struct CombineLatest<A, B, Output> : Publisher where A : Publisher, B : Publisher, A.Failure == B.Failure {

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure

        public let a: A

        public let b: B

        public let transform: (A.Output, B.Output) -> Output

        public init(_ a: A, _ b: B, transform: @escaping (A.Output, B.Output) -> Output)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, B.Failure == S.Failure
    }

    /// A publisher that receives and combines the latest elements from three publishers.
    public struct CombineLatest3<A, B, C, Output> : Publisher where A : Publisher, B : Publisher, C : Publisher, A.Failure == B.Failure, B.Failure == C.Failure {

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure

        public let a: A

        public let b: B

        public let c: C

        public let transform: (A.Output, B.Output, C.Output) -> Output

        public init(_ a: A, _ b: B, _ c: C, transform: @escaping (A.Output, B.Output, C.Output) -> Output)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, C.Failure == S.Failure
    }

    /// A publisher that receives and combines the latest elements from four publishers.
    public struct CombineLatest4<A, B, C, D, Output> : Publisher where A : Publisher, B : Publisher, C : Publisher, D : Publisher, A.Failure == B.Failure, B.Failure == C.Failure, C.Failure == D.Failure {

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure

        public let a: A

        public let b: B

        public let c: C

        public let d: D

        public let transform: (A.Output, B.Output, C.Output, D.Output) -> Output

        public init(_ a: A, _ b: B, _ c: C, _ d: D, transform: @escaping (A.Output, B.Output, C.Output, D.Output) -> Output)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, D.Failure == S.Failure
    }

    /// A publisher that receives and combines the latest elements from two publishers, using a throwing closure.
    public struct TryCombineLatest<A, B, Output> : Publisher where A : Publisher, B : Publisher, A.Failure == Error, B.Failure == Error {

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error

        public let a: A

        public let b: B

        public let transform: (A.Output, B.Output) throws -> Output

        public init(_ a: A, _ b: B, transform: @escaping (A.Output, B.Output) throws -> Output)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, S.Failure == Publishers.TryCombineLatest<A, B, Output>.Failure
    }

    /// A publisher that receives and combines the latest elements from three publishers, using a throwing closure.
    public struct TryCombineLatest3<A, B, C, Output> : Publisher where A : Publisher, B : Publisher, C : Publisher, A.Failure == Error, B.Failure == Error, C.Failure == Error {

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error

        public let a: A

        public let b: B

        public let c: C

        public let transform: (A.Output, B.Output, C.Output) throws -> Output

        public init(_ a: A, _ b: B, _ c: C, transform: @escaping (A.Output, B.Output, C.Output) throws -> Output)


        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, S.Failure == Publishers.TryCombineLatest3<A, B, C, Output>.Failure
    }

    /// A publisher that receives and combines the latest elements from four publishers, using a throwing closure.
    public struct TryCombineLatest4<A, B, C, D, Output> : Publisher where A : Publisher, B : Publisher, C : Publisher, D : Publisher, A.Failure == Error, B.Failure == Error, C.Failure == Error, D.Failure == Error {

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error

        public let a: A

        public let b: B

        public let c: C

        public let d: D

        public let transform: (A.Output, B.Output, C.Output, D.Output) throws -> Output

        public init(_ a: A, _ b: B, _ c: C, _ d: D, transform: @escaping (A.Output, B.Output, C.Output, D.Output) throws -> Output)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, S.Failure == Publishers.TryCombineLatest4<A, B, C, D, Output>.Failure
    }
}


extension Publishers {

    /// A publisher that prints log messages for all publishing events, optionally prefixed with a given string.
    ///
    /// This publisher prints log messages when receiving the following events:
    /// * subscription
    /// * value
    /// * normal completion
    /// * failure
    /// * cancellation
    public struct Print<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// A string with which to prefix all log messages.
        public let prefix: String

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        public let stream: TextOutputStream?

        /// Creates a publisher that prints log messages for all publishing events.
        ///
        /// - Parameters:
        ///   - upstream: The publisher from which this publisher receives elements.
        ///   - prefix: A string with which to prefix all log messages.
        public init(upstream: Upstream, prefix: String, to stream: TextOutputStream? = nil)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }
}

extension Publishers {

    /// A publisher that republishes elements while a predicate closure indicates publishing should continue.
    public struct PrefixWhile<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The closure that determines whether whether publishing should continue.
        public let predicate: (Upstream.Output) -> Bool

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }

    /// A publisher that republishes elements while an error-throwing predicate closure indicates publishing should continue.
    public struct TryPrefixWhile<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The error-throwing closure that determines whether publishing should continue.
        public let predicate: (Upstream.Output) throws -> Bool

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Output == S.Input, S.Failure == Publishers.TryPrefixWhile<Upstream>.Failure
    }
}

extension Publishers {

    /// A publisher that eventually produces one value and then finishes or fails.
    final public class Future<Output, Failure> : Publisher where Failure : Error {

        public typealias Promise = (Result<Output, Failure>) -> Void

        public init(_ attemptToFulfill: @escaping (@escaping Publishers.Future<Output, Failure>.Promise) -> Void)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        final public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber
    }
}

extension Publishers {

    /// A publisher that appears to send a specified failure type.
    ///
    /// The publisher cannot actually fail with the specified type and instead just finishes normally. Use this publisher type when you need to match the error types for two mismatched publishers.
    public struct SetFailureType<Upstream, Failure> : Publisher where Upstream : Publisher, Failure : Error, Upstream.Failure == Never {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// Creates a publisher that appears to send a specified failure type.
        ///
        /// - Parameter upstream: The publisher from which this publisher receives elements.
        public init(upstream: Upstream)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Failure == S.Failure, S : Subscriber, Upstream.Output == S.Input

        public func setFailureType<E>(to failure: E.Type) -> Publishers.SetFailureType<Upstream, E> where E : Error
    }
}

extension Publishers {

    /// A publisher that emits a Boolean value upon receiving an element that satisfies the predicate closure.
    public struct ContainsWhere<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Bool

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The closure that determines whether the publisher should consider an element as a match.
        public let predicate: (Upstream.Output) -> Bool

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, S.Input == Publishers.ContainsWhere<Upstream>.Output
    }

    /// A publisher that emits a Boolean value upon receiving an element that satisfies the throwing predicate closure.
    public struct TryContainsWhere<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Bool

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The error-throwing closure that determines whether this publisher should emit a `true` element.
        public let predicate: (Upstream.Output) throws -> Bool

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Publishers.TryContainsWhere<Upstream>.Failure, S.Input == Publishers.TryContainsWhere<Upstream>.Output
    }
}

extension Publishers {

    public struct MakeConnectable<Upstream> : ConnectablePublisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input

        /// Connects to the publisher and returns a `Cancellable` instance with which to cancel publishing.
        ///
        /// - Returns: A `Cancellable` instance that can be used to cancel publishing.
        public func connect() -> Cancellable
    }
}

extension Publishers {

    /// A strategy for collecting received elements.
    ///
    /// - byTime: Collect and periodically publish items.
    /// - byTimeOrCount: Collect and publish items, either periodically or when a buffer reaches its maximum size.
    public enum TimeGroupingStrategy<Context> where Context : Scheduler {

        case byTime(Context, Context.SchedulerTimeType.Stride)

        case byTimeOrCount(Context, Context.SchedulerTimeType.Stride, Int)
    }

    /// A publisher that buffers and periodically publishes its items.
    public struct CollectByTime<Upstream, Context> : Publisher where Upstream : Publisher, Context : Scheduler {

        /// The kind of values published by this publisher.
        public typealias Output = [Upstream.Output]

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream

        /// The strategy with which to collect and publish elements.
        public let strategy: Publishers.TimeGroupingStrategy<Context>

        /// `Scheduler` options to use for the strategy.
        public let options: Context.SchedulerOptions?

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, S.Input == [Upstream.Output]
    }

    /// A publisher that buffers items.
    public struct Collect<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = [Upstream.Output]

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, S.Input == [Upstream.Output]
    }

    /// A publisher that buffers a maximum number of items.
    public struct CollectByCount<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = [Upstream.Output]

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        ///  The maximum number of received elements to buffer before publishing.
        public let count: Int

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, S.Input == [Upstream.Output]
    }
}

extension Publishers {

    /// A publisher that publishes an optional value to each subscriber exactly once, if the optional has a value.
    ///
    /// If `result` is `.success`, and the value is non-nil, then `Optional` waits until receiving a request for at least 1 value before sending the output. If `result` is `.failure`, then `Optional` sends the failure immediately upon subscription. If `result` is `.success` and the value is nil, then `Optional` sends `.finished` immediately upon subscription.
    ///
    /// In contrast with `Just`, an `Optional` publisher can send an error.
    /// In contrast with `Once`, an `Optional` publisher can send zero values and finish normally, or send zero values and fail with an error.
    public struct Optional<Output, Failure> : Publisher where Failure : Error {

        /// The result to deliver to each subscriber.
        public let result: Result<Output?, Failure>

        /// Creates a publisher to emit the optional value of a successful result, or fail with an error.
        ///
        /// - Parameter result: The result to deliver to each subscriber.
        public init(_ result: Result<Output?, Failure>)

        public init(_ output: Output?)

        public init(_ failure: Failure)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber
    }
}

extension Publishers {

    /// A publisher that delivers elements to its downstream subscriber on a specific scheduler.
    public struct ReceiveOn<Upstream, Context> : Publisher where Upstream : Publisher, Context : Scheduler {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The scheduler the publisher is to use for element delivery.
        public let scheduler: Context

        /// Scheduler options that customize the delivery of elements.
        public let options: Context.SchedulerOptions?

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }
}

extension Publishers {

    public struct PrefixUntilOutput<Upstream, Other> : Publisher where Upstream : Publisher, Other : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// Another publisher, whose first output causes this publisher to finish.
        public let other: Other

        public init(upstream: Upstream, other: Other)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }
}

extension Publishers {

    /// A publisher that applies a closure to all received elements and produces an accumulated value when the upstream publisher finishes.
    public struct Reduce<Upstream, Output> : Publisher where Upstream : Publisher {

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The initial value provided on the first invocation of the closure.
        public let initial: Output

        /// A closure that takes the previously-accumulated value and the next element from the upstream publisher to produce a new value.
        public let nextPartialResult: (Output, Upstream.Output) -> Output

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, Upstream.Failure == S.Failure
    }

    /// A publisher that applies an error-throwing closure to all received elements and produces an accumulated value when the upstream publisher finishes.
    public struct TryReduce<Upstream, Output> : Publisher where Upstream : Publisher {

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The initial value provided on the first invocation of the closure.
        public let initial: Output

        /// An error-throwing closure that takes the previously-accumulated value and the next element from the upstream to produce a new value.
        ///
        /// If this closure throws an error, the publisher fails and passes the error to its subscriber.
        public let nextPartialResult: (Output, Upstream.Output) throws -> Output

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, S.Failure == Publishers.TryReduce<Upstream, Output>.Failure
    }
}

extension Publishers {

    /// A publisher that republishes all non-`nil` results of calling a closure with each received element.
    public struct CompactMap<Upstream, Output> : Publisher where Upstream : Publisher {

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// A closure that receives values from the upstream publisher and returns optional values.
        public let transform: (Upstream.Output) -> Output?

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, Upstream.Failure == S.Failure
    }

    /// A publisher that republishes all non-`nil` results of calling an error-throwing closure with each received element.
    public struct TryCompactMap<Upstream, Output> : Publisher where Upstream : Publisher {

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// an error-throwing closure that receives values from the upstream publisher and returns optional values.
        ///
        /// If this closure throws an error, the publisher fails.
        public let transform: (Upstream.Output) throws -> Output?

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, S.Failure == Publishers.TryCompactMap<Upstream, Output>.Failure
    }
}

extension Publishers {

    public struct Scan<Upstream, Output> : Publisher where Upstream : Publisher {

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        public let upstream: Upstream

        public let nextPartialResult: (Output, Upstream.Output) -> Output

        public let initialResult: Output

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, Upstream.Failure == S.Failure
    }

    public struct TryScan<Upstream, Output> : Publisher where Upstream : Publisher {

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error

        public let upstream: Upstream

        public let nextPartialResult: (Output, Upstream.Output) throws -> Output

        public let initialResult: Output

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, S.Failure == Publishers.TryScan<Upstream, Output>.Failure
    }
}

extension Publishers {

    /// A publisher that only publishes the last element of a stream that satisfies a predicate closure, once the stream finishes.
    public struct LastWhere<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The closure that determines whether to publish an element.
        public let predicate: (Upstream.Output) -> Bool

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }

    /// A publisher that only publishes the last element of a stream that satisfies a error-throwing predicate closure, once the stream finishes.
    public struct TryLastWhere<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The error-throwing closure that determines whether to publish an element.
        public let predicate: (Upstream.Output) throws -> Bool

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Output == S.Input, S.Failure == Publishers.TryLastWhere<Upstream>.Failure
    }
}

extension Publishers {

    /// A publisher that ignores all upstream elements, but passes along a completion state (finish or failed).
    public struct IgnoreOutput<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Never

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, S.Input == Publishers.IgnoreOutput<Upstream>.Output
    }
}

extension Publishers {

    /// A publisher that “flattens” nested publishers.
    ///
    /// Given a publisher that publishes Publishers, the `SwitchToLatest` publisher produces a sequence of events from only the most recent one.
    /// For example, given the type `Publisher<Publisher<Data, NSError>, Never>`, calling `switchToLatest()` will result in the type `Publisher<Data, NSError>`. The downstream subscriber sees a continuous stream of values even though they may be coming from different upstream publishers.
    public struct SwitchToLatest<P, Upstream> : Publisher where P : Publisher, P == Upstream.Output, Upstream : Publisher, P.Failure == Upstream.Failure {

        /// The kind of values published by this publisher.
        public typealias Output = P.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = P.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// Creates a publisher that “flattens” nested publishers.
        ///
        /// - Parameter upstream: The publisher from which this publisher receives elements.
        public init(upstream: Upstream)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, P.Output == S.Input, Upstream.Failure == S.Failure
    }
}

extension Publishers {

    /// A publisher that attempts to recreate its subscription to a failed upstream publisher.
    public struct Retry<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The maximum number of retry attempts to perform.
        ///
        /// If `nil`, this publisher attempts to reconnect with the upstream publisher an unlimited number of times.
        public let retries: Int?

        /// Creates a publisher that attempts to recreate its subscription to a failed upstream publisher.
        ///
        /// - Parameters:
        ///   - upstream: The publisher from which this publisher receives its elements.
        ///   - retries: The maximum number of retry attempts to perform. If `nil`, this publisher attempts to reconnect with the upstream publisher an unlimited number of times.
        public init(upstream: Upstream, retries: Int?)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }
}

extension Publishers {

    /// A publisher that publishes either the most-recent or first element published by the upstream publisher in a specified time interval.
    public struct Throttle<Upstream, Context> : Publisher where Upstream : Publisher, Context : Scheduler {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The interval in which to find and emit the most recent element.
        public let interval: Context.SchedulerTimeType.Stride

        /// The scheduler on which to publish elements.
        public let scheduler: Context

        /// A Boolean value indicating whether to publish the most recent element.
        ///
        /// If `false`, the publisher emits the first element received during the interval.
        public let latest: Bool

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }
}

extension Publishers {

    /// A publisher implemented as a class, which otherwise behaves like its upstream publisher.
    final public class Share<Upstream> : Publisher, Equatable where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        final public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (lhs: Publishers.Share<Upstream>, rhs: Publishers.Share<Upstream>) -> Bool
    }
}

extension Publishers {

    /// A publisher that republishes items from another publisher only if each new item is in increasing order from the previously-published item.
    public struct Comparison<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream

        /// A closure that receives two elements and returns `true` if they are in increasing order.
        public let areInIncreasingOrder: (Upstream.Output, Upstream.Output) -> Bool

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }

    /// A publisher that republishes items from another publisher only if each new item is in increasing order from the previously-published item, and fails if the ordering logic throws an error.
    public struct TryComparison<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error

        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream

        /// A closure that receives two elements and returns `true` if they are in increasing order.
        public let areInIncreasingOrder: (Upstream.Output, Upstream.Output) throws -> Bool

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Output == S.Input, S.Failure == Publishers.TryComparison<Upstream>.Failure
    }
}

extension Publishers {

    /// A publisher that replaces an empty stream with a provided element.
    public struct ReplaceEmpty<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The element to deliver when the upstream publisher finishes without delivering any elements.
        public let output: Upstream.Output

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        public init(upstream: Upstream, output: Publishers.ReplaceEmpty<Upstream>.Output)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }

    /// A publisher that replaces any errors in the stream with a provided element.
    public struct ReplaceError<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Never

        /// The element with which to replace errors from the upstream publisher.
        public let output: Upstream.Output

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        public init(upstream: Upstream, output: Publishers.ReplaceError<Upstream>.Output)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Output == S.Input, S.Failure == Publishers.ReplaceError<Upstream>.Failure
    }
}

extension Publishers {

    /// A publisher that raises a fatal error upon receiving any failure, and otherwise republishes all received input.
    ///
    /// Use this function for internal sanity checks that are active during testing but do not impact performance of shipping code. 
    public struct AssertNoFailure<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Never

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The string used at the beginning of the fatal error message.
        public let prefix: String

        /// The filename used in the error message.
        public let file: StaticString

        /// The line number used in the error message.
        public let line: UInt

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Output == S.Input, S.Failure == Publishers.AssertNoFailure<Upstream>.Failure
    }
}

extension Publishers {

    /// A publisher that ignores elements from the upstream publisher until it receives an element from second publisher.
    public struct DropUntilOutput<Upstream, Other> : Publisher where Upstream : Publisher, Other : Publisher, Upstream.Failure == Other.Failure {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream

        /// A publisher to monitor for its first emitted element.
        public let other: Other

        /// Creates a publisher that ignores elements from the upstream publisher until it receives an element from another publisher.
        ///
        /// - Parameters:
        ///   - upstream: A publisher to drop elements from while waiting for another publisher to emit elements.
        ///   - other: A publisher to monitor for its first emitted element.
        public init(upstream: Upstream, other: Other)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Output == S.Input, Other.Failure == S.Failure
    }
}

extension Publishers {

    /// A publisher that performs the specified closures when publisher events occur.
    public struct HandleEvents<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// A closure that executes when the publisher receives the subscription from the upstream publisher.
        public var receiveSubscription: ((Subscription) -> Void)?

        ///  A closure that executes when the publisher receives a value from the upstream publisher.
        public var receiveOutput: ((Upstream.Output) -> Void)?

        /// A closure that executes when the publisher receives the completion from the upstream publisher.
        public var receiveCompletion: ((Subscribers.Completion<Upstream.Failure>) -> Void)?

        ///  A closure that executes when the downstream receiver cancels publishing.
        public var receiveCancel: (() -> Void)?

        /// A closure that executes when the publisher receives a request for more elements.
        public var receiveRequest: ((Subscribers.Demand) -> Void)?

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }
}

extension Publishers {

    /// A publisher that emits all of one publisher’s elements before those from another publisher.
    public struct Concatenate<Prefix, Suffix> : Publisher where Prefix : Publisher, Suffix : Publisher, Prefix.Failure == Suffix.Failure, Prefix.Output == Suffix.Output {

        /// The kind of values published by this publisher.
        public typealias Output = Suffix.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Suffix.Failure

        /// The publisher to republish, in its entirety, before republishing elements from `suffix`.
        public let prefix: Prefix

        /// The publisher to republish only after `prefix` finishes.
        public let suffix: Suffix

        public init(prefix: Prefix, suffix: Suffix)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Suffix.Failure == S.Failure, Suffix.Output == S.Input
    }
}

extension Publishers {

    /// A publisher that publishes elements only after a specified time interval elapses between events.
    public struct Debounce<Upstream, Context> : Publisher where Upstream : Publisher, Context : Scheduler {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The amount of time the publisher should wait before publishing an element.
        public let dueTime: Context.SchedulerTimeType.Stride

        /// The scheduler on which this publisher delivers elements.
        public let scheduler: Context

        /// Scheduler options that customize this publisher’s delivery of elements.
        public let options: Context.SchedulerOptions?

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }
}

extension Publishers {

    /// A publisher that immediately terminates with the specified error.
    public struct Fail<Output, Failure> : Publisher where Failure : Error {

        /// Creates a publisher that immediately terminates with the specified failure.
        ///
        /// - Parameter error: The failure to send when terminating the publisher.
        public init(error: Failure)

        /// Creates publisher with the given output type, that immediately terminates with the specified failure.
        ///
        /// Use this initializer to create a `Fail` publisher that can work with subscribers or publishers that expect a given output type.
        /// - Parameters:
        ///   - outputType: The output type exposed by this publisher.
        ///   - failure: The failure to send when terminating the publisher.
        public init(outputType: Output.Type, failure: Failure)

        /// The failure to send when terminating the publisher.
        public let error: Failure

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber
    }
}

extension Publishers {

    /// A publisher that only publishes the last element of a stream, after the stream finishes.
    public struct Last<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }
}

extension Publishers {

    public struct Timeout<Upstream, Context> : Publisher where Upstream : Publisher, Context : Scheduler {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        public let upstream: Upstream

        public let interval: Context.SchedulerTimeType.Stride

        public let scheduler: Context

        public let options: Context.SchedulerOptions?

        public let customError: (() -> Upstream.Failure)?

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }
}

extension Publishers {

    public enum PrefetchStrategy {

        case keepFull

        case byRequest

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: Publishers.PrefetchStrategy, b: Publishers.PrefetchStrategy) -> Bool

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        public var hashValue: Int { get }

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
        ///   compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher)
    }

    public enum BufferingStrategy<Failure> where Failure : Error {

        case dropNewest

        case dropOldest

        case customError(() -> Failure)
    }

    public struct Buffer<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        public let upstream: Upstream

        public let size: Int

        public let prefetch: Publishers.PrefetchStrategy

        public let whenFull: Publishers.BufferingStrategy<Upstream.Failure>

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }
}

extension Publishers {

    /// A publisher created by applying the zip function to two upstream publishers.
    public struct Zip<A, B> : Publisher where A : Publisher, B : Publisher, A.Failure == B.Failure {

        /// The kind of values published by this publisher.
        public typealias Output = (A.Output, B.Output)

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure

        public let a: A

        public let b: B

        public init(_ a: A, _ b: B)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, B.Failure == S.Failure, S.Input == (A.Output, B.Output)
    }

    /// A publisher created by applying the zip function to three upstream publishers.
    public struct Zip3<A, B, C> : Publisher where A : Publisher, B : Publisher, C : Publisher, A.Failure == B.Failure, B.Failure == C.Failure {

        /// The kind of values published by this publisher.
        public typealias Output = (A.Output, B.Output, C.Output)

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure

        public let a: A

        public let b: B

        public let c: C

        public init(_ a: A, _ b: B, _ c: C)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, C.Failure == S.Failure, S.Input == (A.Output, B.Output, C.Output)
    }

    /// A publisher created by applying the zip function to four upstream publishers.
    public struct Zip4<A, B, C, D> : Publisher where A : Publisher, B : Publisher, C : Publisher, D : Publisher, A.Failure == B.Failure, B.Failure == C.Failure, C.Failure == D.Failure {

        /// The kind of values published by this publisher.
        public typealias Output = (A.Output, B.Output, C.Output, D.Output)

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure

        public let a: A

        public let b: B

        public let c: C

        public let d: D

        public init(_ a: A, _ b: B, _ c: C, _ d: D)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, D.Failure == S.Failure, S.Input == (A.Output, B.Output, C.Output, D.Output)
    }
}

extension Publishers {

    /// A publisher that publishes elements specified by a range in the sequence of published elements.
    public struct Output<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream

        /// The range of elements to publish.
        public let range: CountableRange<Int>

        /// Creates a publisher that publishes elements specified by a range.
        ///
        /// - Parameters:
        ///   - upstream: The publisher that this publisher receives elements from.
        ///   - range: The range of elements to publish.
        public init(upstream: Upstream, range: CountableRange<Int>)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }
}

extension Publishers {

    /// A publisher that handles errors from an upstream publisher by replacing the failed publisher with another publisher.
    public struct Catch<Upstream, NewPublisher> : Publisher where Upstream : Publisher, NewPublisher : Publisher, Upstream.Output == NewPublisher.Output {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = NewPublisher.Failure

        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream

        /// A closure that accepts the upstream failure as input and returns a publisher to replace the upstream publisher.
        public let handler: (Upstream.Failure) -> NewPublisher

        /// Creates a publisher that handles errors from an upstream publisher by replacing the failed publisher with another publisher.
        ///
        /// - Parameters:
        ///   - upstream: The publisher that this publisher receives elements from.
        ///   - handler: A closure that accepts the upstream failure as input and returns a publisher to replace the upstream publisher.
        public init(upstream: Upstream, handler: @escaping (Upstream.Failure) -> NewPublisher)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, NewPublisher.Failure == S.Failure, NewPublisher.Output == S.Input
    }
}

extension Publishers {

    /// A publisher that delays delivery of elements and completion to the downstream receiver.
    public struct Delay<Upstream, Context> : Publisher where Upstream : Publisher, Context : Scheduler {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream

        /// The amount of time to delay.
        public let interval: Context.SchedulerTimeType.Stride

        /// The allowed tolerance in firing delayed events.
        public let tolerance: Context.SchedulerTimeType.Stride

        /// The scheduler to deliver the delayed events.
        public let scheduler: Context

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }
}

extension Publishers {

    /// A publisher that omits a specified number of elements before republishing later elements.
    public struct Drop<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The number of elements to drop.
        public let count: Int

        public init(upstream: Upstream, count: Int)

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }
}

extension Publishers {

    /// A publisher that publishes the first element of a stream, then finishes.
    public struct First<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }

    /// A publisher that only publishes the first element of a stream to satisfy a predicate closure.
    public struct FirstWhere<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The closure that determines whether to publish an element.
        public let predicate: (Upstream.Output) -> Bool

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
    }

    /// A publisher that only publishes the first element of a stream to satisfy a throwing predicate closure.
    public struct TryFirstWhere<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The error-throwing closure that determines whether to publish an element.
        public let predicate: (Upstream.Output) throws -> Bool

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Output == S.Input, S.Failure == Publishers.TryFirstWhere<Upstream>.Failure
    }
}

extension Publishers.Filter {

    public func filter(_ isIncluded: @escaping (Publishers.Filter<Upstream>.Output) -> Bool) -> Publishers.Filter<Upstream>

    public func tryFilter(_ isIncluded: @escaping (Publishers.Filter<Upstream>.Output) throws -> Bool) -> Publishers.TryFilter<Upstream>
}

extension Publishers.TryFilter {

    public func filter(_ isIncluded: @escaping (Publishers.TryFilter<Upstream>.Output) -> Bool) -> Publishers.TryFilter<Upstream>

    public func tryFilter(_ isIncluded: @escaping (Publishers.TryFilter<Upstream>.Output) throws -> Bool) -> Publishers.TryFilter<Upstream>
}

extension Publishers.Just {

    public func allSatisfy(_ predicate: (Output) -> Bool) -> Publishers.Just<Bool>

    public func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Publishers.Once<Bool, Error>

    public func collect() -> Publishers.Just<[Output]>

    public func compactMap<T>(_ transform: (Output) -> T?) -> Publishers.Optional<T, Publishers.Just<Output>.Failure>

    public func tryCompactMap<T>(_ transform: (Output) throws -> T?) -> Publishers.Optional<T, Error>

    public func min(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Just<Output>

    public func tryMin(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Optional<Output>

    public func max(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Just<Output>

    public func tryMax(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Optional<Output>

    public func prepend(_ elements: Output...) -> Publishers.Sequence<[Output], Publishers.Just<Output>.Failure>

    public func prepend<S>(_ elements: S) -> Publishers.Sequence<[Output], Publishers.Just<Output>.Failure> where Output == S.Element, S : Sequence

    public func append(_ elements: Output...) -> Publishers.Sequence<[Output], Publishers.Just<Output>.Failure>

    public func append<S>(_ elements: S) -> Publishers.Sequence<[Output], Publishers.Just<Output>.Failure> where Output == S.Element, S : Sequence

    public func contains(where predicate: (Output) -> Bool) -> Publishers.Just<Bool>

    public func tryContains(where predicate: (Output) throws -> Bool) -> Publishers.Once<Bool, Error>

    public func count() -> Publishers.Just<Int>

    public func dropFirst(_ count: Int = 1) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure>

    public func drop(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure>

    public func tryDrop(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error>

    public func first() -> Publishers.Just<Output>

    public func first(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure>

    public func tryFirst(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error>

    public func last() -> Publishers.Just<Output>

    public func last(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure>

    public func tryLast(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error>

    public func filter(_ isIncluded: (Output) -> Bool) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure>

    public func tryFilter(_ isIncluded: (Output) throws -> Bool) -> Publishers.Optional<Output, Error>

    public func ignoreOutput() -> Publishers.Empty<Output, Publishers.Just<Output>.Failure>

    public func map<T>(_ transform: (Output) -> T) -> Publishers.Just<T>

    public func tryMap<T>(_ transform: (Output) throws -> T) -> Publishers.Once<T, Error>

    public func mapError<E>(_ transform: (Publishers.Just<Output>.Failure) -> E) -> Publishers.Once<Output, E> where E : Error

    public func output(at index: Int) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure>

    public func output<R>(in range: R) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> where R : RangeExpression, R.Bound == Int

    public func prefix(_ maxLength: Int) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure>

    public func prefix(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure>

    public func tryPrefix(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error>

    public func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Once<T, Publishers.Just<Output>.Failure>

    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Once<T, Error>

    public func removeDuplicates(by predicate: (Output, Output) -> Bool) -> Publishers.Just<Output>

    public func tryRemoveDuplicates(by predicate: (Output, Output) throws -> Bool) -> Publishers.Once<Output, Error>

    public func replaceError(with output: Output) -> Publishers.Just<Output>

    public func replaceEmpty(with output: Output) -> Publishers.Just<Output>

    public func retry(_ times: Int) -> Publishers.Just<Output>

    public func retry() -> Publishers.Just<Output>

    public func scan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Once<T, Publishers.Just<Output>.Failure>

    public func tryScan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Once<T, Error>

    public func setFailureType<E>(to failureType: E.Type) -> Publishers.Once<Output, E> where E : Error
}

extension Publishers.Contains : Equatable where Upstream : Equatable {

    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A contains publisher to compare for equality.
    ///   - rhs: Another contains publisher to compare for equality.
    /// - Returns: `true` if the two publishers’ upstream and output properties are equal, `false` otherwise.
    public static func == (lhs: Publishers.Contains<Upstream>, rhs: Publishers.Contains<Upstream>) -> Bool
}

extension Publishers.SetFailureType : Equatable where Upstream : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.SetFailureType<Upstream, Failure>, rhs: Publishers.SetFailureType<Upstream, Failure>) -> Bool
}

extension Publishers.Collect : Equatable where Upstream : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.Collect<Upstream>, rhs: Publishers.Collect<Upstream>) -> Bool
}

extension Publishers.CollectByCount : Equatable where Upstream : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.CollectByCount<Upstream>, rhs: Publishers.CollectByCount<Upstream>) -> Bool
}

extension Publishers.Optional : Equatable where Output : Equatable, Failure : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.Optional<Output, Failure>, rhs: Publishers.Optional<Output, Failure>) -> Bool
}

extension Publishers.Optional where Output : Equatable {

    public func contains(_ output: Output) -> Publishers.Optional<Bool, Failure>

    public func removeDuplicates() -> Publishers.Optional<Output, Failure>
}

extension Publishers.Optional where Output : Comparable {

    public func min() -> Publishers.Optional<Output, Failure>

    public func max() -> Publishers.Optional<Output, Failure>
}

extension Publishers.Optional {

    public func allSatisfy(_ predicate: (Output) -> Bool) -> Publishers.Optional<Bool, Failure>

    public func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Publishers.Optional<Bool, Error>

    public func collect() -> Publishers.Optional<[Output], Failure>

    public func compactMap<T>(_ transform: (Output) -> T?) -> Publishers.Optional<T, Failure>

    public func tryCompactMap<T>(_ transform: (Output) throws -> T?) -> Publishers.Optional<T, Error>

    public func min(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Optional<Output, Failure>

    public func tryMin(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Optional<Output, Failure>

    public func max(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Optional<Output, Failure>

    public func tryMax(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Optional<Output, Failure>

    public func contains(where predicate: (Output) -> Bool) -> Publishers.Optional<Bool, Failure>

    public func tryContains(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Bool, Error>

    public func count() -> Publishers.Optional<Int, Failure>

    public func dropFirst(_ count: Int = 1) -> Publishers.Optional<Output, Failure>

    public func drop(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure>

    public func tryDrop(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error>

    public func first() -> Publishers.Optional<Output, Failure>

    public func first(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure>

    public func tryFirst(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error>

    public func last() -> Publishers.Optional<Output, Failure>

    public func last(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure>

    public func tryLast(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error>

    public func filter(_ isIncluded: (Output) -> Bool) -> Publishers.Optional<Output, Failure>

    public func tryFilter(_ isIncluded: (Output) throws -> Bool) -> Publishers.Optional<Output, Error>

    public func ignoreOutput() -> Publishers.Empty<Output, Failure>

    public func map<T>(_ transform: (Output) -> T) -> Publishers.Optional<T, Failure>

    public func tryMap<T>(_ transform: (Output) throws -> T) -> Publishers.Optional<T, Error>

    public func mapError<E>(_ transform: (Failure) -> E) -> Publishers.Optional<Output, E> where E : Error

    public func output(at index: Int) -> Publishers.Optional<Output, Failure>

    public func output<R>(in range: R) -> Publishers.Optional<Output, Failure> where R : RangeExpression, R.Bound == Int

    public func prefix(_ maxLength: Int) -> Publishers.Optional<Output, Failure>

    public func prefix(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure>

    public func tryPrefix(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error>

    public func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Optional<T, Failure>

    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Optional<T, Error>

    public func removeDuplicates(by predicate: (Output, Output) -> Bool) -> Publishers.Optional<Output, Failure>

    public func tryRemoveDuplicates(by predicate: (Output, Output) throws -> Bool) -> Publishers.Optional<Output, Error>

    public func replaceError(with output: Output) -> Publishers.Optional<Output, Never>

    public func replaceEmpty(with output: Output) -> Publishers.Optional<Output, Failure>

    public func retry(_ times: Int) -> Publishers.Optional<Output, Failure>

    public func retry() -> Publishers.Optional<Output, Failure>

    public func scan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Optional<T, Failure>

    public func tryScan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Optional<T, Error>
}

extension Publishers.Optional where Failure == Never {

    public func setFailureType<E>(to failureType: E.Type) -> Publishers.Optional<Output, E> where E : Error
}

extension Publishers.CompactMap {

    public func compactMap<T>(_ transform: @escaping (Output) -> T?) -> Publishers.CompactMap<Upstream, T>

    public func map<T>(_ transform: @escaping (Output) -> T) -> Publishers.CompactMap<Upstream, T>
}

extension Publishers.TryCompactMap {

    public func compactMap<T>(_ transform: @escaping (Output) throws -> T?) -> Publishers.TryCompactMap<Upstream, T>
}

extension Publishers.Merge : Equatable where A : Equatable, B : Equatable {

    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A merging publisher to compare for equality.
    ///   - rhs: Another merging publisher to compare for equality..
    /// - Returns: `true` if the two merging - rhs: Another merging publisher to compare for equality.
    public static func == (lhs: Publishers.Merge<A, B>, rhs: Publishers.Merge<A, B>) -> Bool
}

extension Publishers.Merge3 : Equatable where A : Equatable, B : Equatable, C : Equatable {

    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A merging publisher to compare for equality.
    ///   - rhs: Another merging publisher to compare for equality.
    /// - Returns: `true` if the two merging publishers have equal source publishers, `false` otherwise.
    public static func == (lhs: Publishers.Merge3<A, B, C>, rhs: Publishers.Merge3<A, B, C>) -> Bool
}

extension Publishers.Merge4 : Equatable where A : Equatable, B : Equatable, C : Equatable, D : Equatable {

    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A merging publisher to compare for equality.
    ///   - rhs: Another merging publisher to compare for equality.
    /// - Returns: `true` if the two merging publishers have equal source publishers, `false` otherwise.
    public static func == (lhs: Publishers.Merge4<A, B, C, D>, rhs: Publishers.Merge4<A, B, C, D>) -> Bool
}

extension Publishers.Merge5 : Equatable where A : Equatable, B : Equatable, C : Equatable, D : Equatable, E : Equatable {

    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A merging publisher to compare for equality.
    ///   - rhs: Another merging publisher to compare for equality.
    /// - Returns: `true` if the two merging publishers have equal source publishers, `false` otherwise.
    public static func == (lhs: Publishers.Merge5<A, B, C, D, E>, rhs: Publishers.Merge5<A, B, C, D, E>) -> Bool
}

extension Publishers.Merge6 : Equatable where A : Equatable, B : Equatable, C : Equatable, D : Equatable, E : Equatable, F : Equatable {

    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A merging publisher to compare for equality.
    ///   - rhs: Another merging publisher to compare for equality.
    /// - Returns: `true` if the two merging publishers have equal source publishers, `false` otherwise.
    public static func == (lhs: Publishers.Merge6<A, B, C, D, E, F>, rhs: Publishers.Merge6<A, B, C, D, E, F>) -> Bool
}

extension Publishers.Merge7 : Equatable where A : Equatable, B : Equatable, C : Equatable, D : Equatable, E : Equatable, F : Equatable, G : Equatable {

    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A merging publisher to compare for equality.
    ///   - rhs: Another merging publisher to compare for equality.
    /// - Returns: `true` if the two merging publishers have equal source publishers, `false` otherwise.
    public static func == (lhs: Publishers.Merge7<A, B, C, D, E, F, G>, rhs: Publishers.Merge7<A, B, C, D, E, F, G>) -> Bool
}

extension Publishers.Merge8 : Equatable where A : Equatable, B : Equatable, C : Equatable, D : Equatable, E : Equatable, F : Equatable, G : Equatable, H : Equatable {

    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A merging publisher to compare for equality.
    ///   - rhs: Another merging publisher to compare for equality.
    /// - Returns: `true` if the two merging publishers have equal source publishers, `false` otherwise.
    public static func == (lhs: Publishers.Merge8<A, B, C, D, E, F, G, H>, rhs: Publishers.Merge8<A, B, C, D, E, F, G, H>) -> Bool
}

extension Publishers.MergeMany : Equatable where Upstream : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.MergeMany<Upstream>, rhs: Publishers.MergeMany<Upstream>) -> Bool
}

extension Publishers.Once {

    public func allSatisfy(_ predicate: (Output) -> Bool) -> Publishers.Once<Bool, Failure>

    public func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Publishers.Once<Bool, Error>

    public func collect() -> Publishers.Once<[Output], Failure>

    public func compactMap<T>(_ transform: (Output) -> T?) -> Publishers.Optional<T, Failure>

    public func tryCompactMap<T>(_ transform: (Output) throws -> T?) -> Publishers.Optional<T, Error>

    public func min(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Once<Output, Failure>

    public func tryMin(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Once<Output, Failure>

    public func max(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Once<Output, Failure>

    public func tryMax(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Once<Output, Failure>

    public func contains(where predicate: (Output) -> Bool) -> Publishers.Once<Bool, Failure>

    public func tryContains(where predicate: (Output) throws -> Bool) -> Publishers.Once<Bool, Error>

    public func count() -> Publishers.Once<Int, Failure>

    public func dropFirst(_ count: Int = 1) -> Publishers.Optional<Output, Failure>

    public func drop(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure>

    public func tryDrop(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error>

    public func first() -> Publishers.Once<Output, Failure>

    public func first(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure>

    public func tryFirst(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error>

    public func last() -> Publishers.Once<Output, Failure>

    public func last(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure>

    public func tryLast(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error>

    public func filter(_ isIncluded: (Output) -> Bool) -> Publishers.Optional<Output, Failure>

    public func tryFilter(_ isIncluded: (Output) throws -> Bool) -> Publishers.Optional<Output, Error>

    public func ignoreOutput() -> Publishers.Empty<Output, Failure>

    public func map<T>(_ transform: (Output) -> T) -> Publishers.Once<T, Failure>

    public func tryMap<T>(_ transform: (Output) throws -> T) -> Publishers.Once<T, Error>

    public func mapError<E>(_ transform: (Failure) -> E) -> Publishers.Once<Output, E> where E : Error

    public func output(at index: Int) -> Publishers.Optional<Output, Failure>

    public func output<R>(in range: R) -> Publishers.Optional<Output, Failure> where R : RangeExpression, R.Bound == Int

    public func prefix(_ maxLength: Int) -> Publishers.Optional<Output, Failure>

    public func prefix(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure>

    public func tryPrefix(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error>

    public func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Once<T, Failure>

    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Once<T, Error>

    public func removeDuplicates(by predicate: (Output, Output) -> Bool) -> Publishers.Once<Output, Failure>

    public func tryRemoveDuplicates(by predicate: (Output, Output) throws -> Bool) -> Publishers.Once<Output, Error>

    public func replaceError(with output: Output) -> Publishers.Once<Output, Never>

    public func replaceEmpty(with output: Output) -> Publishers.Once<Output, Failure>

    public func retry(_ times: Int) -> Publishers.Once<Output, Failure>

    public func retry() -> Publishers.Once<Output, Failure>

    public func scan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Once<T, Failure>

    public func tryScan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Once<T, Error>
}

extension Publishers.Once where Failure == Never {

    public func setFailureType<E>(to failureType: E.Type) -> Publishers.Once<Output, E> where E : Error
}

extension Publishers.IgnoreOutput : Equatable where Upstream : Equatable {

    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: An ignore output publisher to compare for equality.
    ///   - rhs: Another ignore output publisher to compare for equality.
    /// - Returns: `true` if the two publishers have equal upstream publishers, `false` otherwise.
    public static func == (lhs: Publishers.IgnoreOutput<Upstream>, rhs: Publishers.IgnoreOutput<Upstream>) -> Bool
}

extension Publishers.Retry : Equatable where Upstream : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.Retry<Upstream>, rhs: Publishers.Retry<Upstream>) -> Bool
}

extension Publishers.ReplaceEmpty : Equatable where Upstream : Equatable, Upstream.Output : Equatable {

    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A replace empty publisher to compare for equality.
    ///   - rhs: Another replace empty publisher to compare for equality.
    /// - Returns: `true` if the two publishers have equal upstream publishers and output elements, `false` otherwise.
    public static func == (lhs: Publishers.ReplaceEmpty<Upstream>, rhs: Publishers.ReplaceEmpty<Upstream>) -> Bool
}

extension Publishers.ReplaceError : Equatable where Upstream : Equatable, Upstream.Output : Equatable {

    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A replace error publisher to compare for equality.
    ///   - rhs: Another replace error publisher to compare for equality.
    /// - Returns: `true` if the two publishers have equal upstream publishers and output elements, `false` otherwise.
    public static func == (lhs: Publishers.ReplaceError<Upstream>, rhs: Publishers.ReplaceError<Upstream>) -> Bool
}

extension Publishers.DropUntilOutput : Equatable where Upstream : Equatable, Other : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.DropUntilOutput<Upstream, Other>, rhs: Publishers.DropUntilOutput<Upstream, Other>) -> Bool
}

extension Publishers.Concatenate : Equatable where Prefix : Equatable, Suffix : Equatable {

    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A concatenate publisher to compare for equality.
    ///   - rhs: Another concatenate publisher to compare for equality.
    /// - Returns: `true` if the two publishers’ prefix and suffix properties are equal, `false` otherwise.
    public static func == (lhs: Publishers.Concatenate<Prefix, Suffix>, rhs: Publishers.Concatenate<Prefix, Suffix>) -> Bool
}

extension Publishers.Fail : Equatable where Failure : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.Fail<Output, Failure>, rhs: Publishers.Fail<Output, Failure>) -> Bool
}

extension Publishers.Last : Equatable where Upstream : Equatable {

    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A last publisher to compare for equality.
    ///   - rhs: Another last publisher to compare for equality.
    /// - Returns: `true` if the two publishers have equal upstream publishers, `false` otherwise.
    public static func == (lhs: Publishers.Last<Upstream>, rhs: Publishers.Last<Upstream>) -> Bool
}

extension Publishers.Map {

    public func map<T>(_ transform: @escaping (Output) -> T) -> Publishers.Map<Upstream, T>

    public func tryMap<T>(_ transform: @escaping (Output) throws -> T) -> Publishers.TryMap<Upstream, T>
}

extension Publishers.TryMap {

    public func map<T>(_ transform: @escaping (Output) -> T) -> Publishers.TryMap<Upstream, T>

    public func tryMap<T>(_ transform: @escaping (Output) throws -> T) -> Publishers.TryMap<Upstream, T>
}

extension Publishers.Sequence {

    public func allSatisfy(_ predicate: (Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Once<Bool, Failure>

    public func tryAllSatisfy(_ predicate: (Publishers.Sequence<Elements, Failure>.Output) throws -> Bool) -> Publishers.Once<Bool, Error>

    public func collect() -> Publishers.Once<[Publishers.Sequence<Elements, Failure>.Output], Failure>

    public func compactMap<T>(_ transform: (Publishers.Sequence<Elements, Failure>.Output) -> T?) -> Publishers.Sequence<[T], Failure>

    public func min(by areInIncreasingOrder: (Publishers.Sequence<Elements, Failure>.Output, Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure>

    public func tryMin(by areInIncreasingOrder: (Publishers.Sequence<Elements, Failure>.Output, Publishers.Sequence<Elements, Failure>.Output) throws -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Error>

    public func max(by areInIncreasingOrder: (Publishers.Sequence<Elements, Failure>.Output, Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure>

    public func tryMax(by areInIncreasingOrder: (Publishers.Sequence<Elements, Failure>.Output, Publishers.Sequence<Elements, Failure>.Output) throws -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Error>

    public func contains(where predicate: (Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Once<Bool, Failure>

    public func tryContains(where predicate: (Publishers.Sequence<Elements, Failure>.Output) throws -> Bool) -> Publishers.Once<Bool, Error>

    public func drop(while predicate: (Elements.Element) -> Bool) -> Publishers.Sequence<DropWhileSequence<Elements>, Failure>

    public func dropFirst(_ count: Int = 1) -> Publishers.Sequence<DropFirstSequence<Elements>, Failure>

    public func first(where predicate: (Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure>

    public func tryFirst(where predicate: (Publishers.Sequence<Elements, Failure>.Output) throws -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Error>

    public func filter(_ isIncluded: (Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Sequence<[Publishers.Sequence<Elements, Failure>.Output], Failure>

    public func ignoreOutput() -> Publishers.Empty<Publishers.Sequence<Elements, Failure>.Output, Failure>

    public func map<T>(_ transform: (Elements.Element) -> T) -> Publishers.Sequence<[T], Failure>

    public func prefix(_ maxLength: Int) -> Publishers.Sequence<PrefixSequence<Elements>, Failure>

    public func prefix(while predicate: (Elements.Element) -> Bool) -> Publishers.Sequence<[Elements.Element], Failure>

    public func reduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Publishers.Sequence<Elements, Failure>.Output) -> T) -> Publishers.Once<T, Failure>

    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Publishers.Sequence<Elements, Failure>.Output) throws -> T) -> Publishers.Once<T, Error>

    public func replaceNil<T>(with output: T) -> Publishers.Sequence<[Publishers.Sequence<Elements, Failure>.Output], Failure> where Elements.Element == T?

    public func scan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Publishers.Sequence<Elements, Failure>.Output) -> T) -> Publishers.Sequence<[T], Failure>

    public func setFailureType<E>(to error: E.Type) -> Publishers.Sequence<Elements, E> where E : Error
}

extension Publishers.Sequence where Elements.Element : Equatable {

    public func removeDuplicates() -> Publishers.Sequence<[Publishers.Sequence<Elements, Failure>.Output], Failure>

    public func contains(_ output: Elements.Element) -> Publishers.Once<Bool, Failure>
}

extension Publishers.Sequence where Elements.Element : Comparable {

    public func min() -> Publishers.Optional<Elements.Element, Failure>

    public func max() -> Publishers.Optional<Elements.Element, Failure>
}

extension Publishers.Sequence where Elements : Collection {

    public func first() -> Publishers.Optional<Elements.Element, Failure>
}

extension Publishers.Sequence where Elements : Collection {

    public func count() -> Publishers.Once<Int, Failure>
}

extension Publishers.Sequence where Elements : Collection {

    public func output(at index: Elements.Index) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure>

    public func output(in range: Range<Elements.Index>) -> Publishers.Sequence<[Publishers.Sequence<Elements, Failure>.Output], Failure>
}

extension Publishers.Sequence where Elements : BidirectionalCollection {

    public func last() -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure>

    public func last(where predicate: (Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure>

    public func tryLast(where predicate: (Publishers.Sequence<Elements, Failure>.Output) throws -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Error>
}

extension Publishers.Sequence where Elements : RandomAccessCollection {

    public func output(at index: Elements.Index) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure>

    public func output(in range: Range<Elements.Index>) -> Publishers.Sequence<[Publishers.Sequence<Elements, Failure>.Output], Failure>
}

extension Publishers.Sequence where Elements : RandomAccessCollection {

    public func count() -> Publishers.Optional<Int, Failure>
}

extension Publishers.Sequence where Elements : RangeReplaceableCollection {

    public func prepend(_ elements: Publishers.Sequence<Elements, Failure>.Output...) -> Publishers.Sequence<Elements, Failure>

    public func prepend<S>(_ elements: S) -> Publishers.Sequence<Elements, Failure> where S : Sequence, Elements.Element == S.Element

    public func prepend(_ publisher: Publishers.Sequence<Elements, Failure>) -> Publishers.Sequence<Elements, Failure>

    public func append(_ elements: Publishers.Sequence<Elements, Failure>.Output...) -> Publishers.Sequence<Elements, Failure>

    public func append<S>(_ elements: S) -> Publishers.Sequence<Elements, Failure> where S : Sequence, Elements.Element == S.Element

    public func append(_ publisher: Publishers.Sequence<Elements, Failure>) -> Publishers.Sequence<Elements, Failure>
}

extension Publishers.Sequence : Equatable where Elements : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.Sequence<Elements, Failure>, rhs: Publishers.Sequence<Elements, Failure>) -> Bool
}

extension Publishers.Zip : Equatable where A : Equatable, B : Equatable {

    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A zip publisher to compare for equality.
    ///   - rhs: Another zip publisher to compare for equality.
    /// - Returns: `true` if the corresponding upstream publishers of each zip publisher are equal, `false` otherwise.
    public static func == (lhs: Publishers.Zip<A, B>, rhs: Publishers.Zip<A, B>) -> Bool
}

/// Returns a Boolean value that indicates whether two publishers are equivalent.
///
/// - Parameters:
///   - lhs: A zip publisher to compare for equality.
///   - rhs: Another zip publisher to compare for equality.
/// - Returns: `true` if the corresponding upstream publishers of each zip publisher are equal, `false` otherwise.
extension Publishers.Zip3 : Equatable where A : Equatable, B : Equatable, C : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.Zip3<A, B, C>, rhs: Publishers.Zip3<A, B, C>) -> Bool
}

/// Returns a Boolean value that indicates whether two publishers are equivalent.
///
/// - Parameters:
///   - lhs: A zip publisher to compare for equality.
///   - rhs: Another zip publisher to compare for equality.
/// - Returns: `true` if the corresponding upstream publishers of each zip publisher are equal, `false` otherwise.
extension Publishers.Zip4 : Equatable where A : Equatable, B : Equatable, C : Equatable, D : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.Zip4<A, B, C, D>, rhs: Publishers.Zip4<A, B, C, D>) -> Bool
}

extension Publishers.Output : Equatable where Upstream : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.Output<Upstream>, rhs: Publishers.Output<Upstream>) -> Bool
}

extension Publishers.Drop : Equatable where Upstream : Equatable {

    /// Returns a Boolean value that indicates whether the two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A drop publisher to compare for equality..
    ///   - rhs: Another drop publisher to compare for equality..
    /// - Returns: `true` if the publishers have equal upstream and count properties, `false` otherwise.
    public static func == (lhs: Publishers.Drop<Upstream>, rhs: Publishers.Drop<Upstream>) -> Bool
}

extension Publishers.First : Equatable where Upstream : Equatable {

    /// Returns a Boolean value that indicates whether two first publishers have equal upstream publishers.
    ///
    /// - Parameters:
    ///   - lhs: A drop publisher to compare for equality.
    ///   - rhs: Another drop publisher to compare for equality.
    /// - Returns: `true` if the two publishers have equal upstream publishers, `false` otherwise.
    public static func == (lhs: Publishers.First<Upstream>, rhs: Publishers.First<Upstream>) -> Bool
}

/// A protocol that defines when and how to execute a closure.
///
/// A scheduler used to execute code as soon as possible, or after a future date.
/// Individual scheduler implementations use whatever time-keeping system makes sense for them. Schdedulers express this as their `SchedulerTimeType`. Since this type conforms to `SchedulerTimeIntervalConvertible`, you can always express these times with the convenience functions like `.milliseconds(500)`.
/// Schedulers can accept options to control how they execute the actions passed to them. These options may control factors like which threads or dispatch queues execute the actions.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol Scheduler {

    /// Describes an instant in time for this scheduler.
    associatedtype SchedulerTimeType : Strideable where Self.SchedulerTimeType.Stride : SchedulerTimeIntervalConvertible

    /// A type that defines options accepted by the scheduler.
    ///
    /// This type is freely definable by each `Scheduler`. Typically, operations that take a `Scheduler` parameter will also take `SchedulerOptions`.
    associatedtype SchedulerOptions

    /// Returns this scheduler's definition of the current moment in time.
    var now: Self.SchedulerTimeType { get }

    /// Returns the minimum tolerance allowed by the scheduler.
    var minimumTolerance: Self.SchedulerTimeType.Stride { get }

    /// Performs the action at the next possible opportunity.
    func schedule(options: Self.SchedulerOptions?, _ action: @escaping () -> Void)

    /// Performs the action at some time after the specified date.
    func schedule(after date: Self.SchedulerTimeType, tolerance: Self.SchedulerTimeType.Stride, options: Self.SchedulerOptions?, _ action: @escaping () -> Void)

    /// Performs the action at some time after the specified date, at the specified
    /// frequency, optionally taking into account tolerance if possible.
    func schedule(after date: Self.SchedulerTimeType, interval: Self.SchedulerTimeType.Stride, tolerance: Self.SchedulerTimeType.Stride, options: Self.SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable
}

extension Scheduler {

    /// Performs the action at some time after the specified date, using the scheduler’s minimum tolerance.
    public func schedule(after date: Self.SchedulerTimeType, _ action: @escaping () -> Void)

    /// Performs the action at the next possible opportunity, without options.
    public func schedule(_ action: @escaping () -> Void)

    /// Performs the action at some time after the specified date.
    public func schedule(after date: Self.SchedulerTimeType, tolerance: Self.SchedulerTimeType.Stride, _ action: @escaping () -> Void)

    /// Performs the action at some time after the specified date, at the specified
    /// frequency, taking into account tolerance if possible.
    public func schedule(after date: Self.SchedulerTimeType, interval: Self.SchedulerTimeType.Stride, tolerance: Self.SchedulerTimeType.Stride, _ action: @escaping () -> Void) -> Cancellable

    /// Performs the action at some time after the specified date, at the specified
    /// frequency, using minimum tolerance possible for this Scheduler.
    public func schedule(after date: Self.SchedulerTimeType, interval: Self.SchedulerTimeType.Stride, _ action: @escaping () -> Void) -> Cancellable
}

/// A protocol that provides a scheduler with an expression for relative time.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol SchedulerTimeIntervalConvertible {

    static func seconds(_ s: Int) -> Self

    static func seconds(_ s: Double) -> Self

    static func milliseconds(_ ms: Int) -> Self

    static func microseconds(_ us: Int) -> Self

    static func nanoseconds(_ ns: Int) -> Self
}

/// A publisher that exposes a method for outside callers to publish elements.
///
/// A subject is a publisher that you can use to ”inject” values into a stream, by calling its `send()` method. This can be useful for adapting existing imperative code to the Combine model.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol Subject : AnyObject, Publisher {

    /// Sends a value to the subscriber.
    ///
    /// - Parameter value: The value to send.
    func send(_ value: Self.Output)

    /// Sends a completion signal to the subscriber.
    ///
    /// - Parameter completion: A `Completion` instance which indicates whether publishing has finished normally or failed with an error.
    func send(completion: Subscribers.Completion<Self.Failure>)
}

extension Subject {

    public func eraseToAnySubject() -> AnySubject<Self.Output, Self.Failure>
}

/// A protocol that declares a type that can receive input from a publisher.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol Subscriber : CustomCombineIdentifierConvertible {

    /// The kind of values this subscriber receives.
    associatedtype Input

    /// The kind of errors this subscriber might receive.
    ///
    /// Use `Never` if this `Subscriber` cannot receive errors.
    associatedtype Failure : Error

    /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
    ///
    /// Use the received `Subscription` to request items from the publisher.
    /// - Parameter subscription: A subscription that represents the connection between publisher and subscriber.
    func receive(subscription: Subscription)

    /// Tells the subscriber that the publisher has produced an element.
    ///
    /// - Parameter input: The published element.
    /// - Returns: A `Demand` instance indicating how many more elements the subcriber expects to receive.
    func receive(_ input: Self.Input) -> Subscribers.Demand

    /// Tells the subscriber that the publisher has completed publishing, either normally or with an error.
    ///
    /// - Parameter completion: A `Completion` case indicating whether publishing completed normally or with an error.
    func receive(completion: Subscribers.Completion<Self.Failure>)
}

extension Subscriber {

    public func eraseToAnySubscriber() -> AnySubscriber<Self.Input, Self.Failure>
}

/// A namespace for types related to the `Subscriber` protocol.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public enum Subscribers {
}

extension Subscribers {

    /// A simple subscriber that requests an unlimited number of values upon subscription.
    final public class Sink<Upstream> : Subscriber, Cancellable, CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible where Upstream : Publisher {

        /// The kind of values this subscriber receives.
        public typealias Input = Upstream.Output

        /// The kind of errors this subscriber might receive.
        ///
        /// Use `Never` if this `Subscriber` cannot receive errors.
        public typealias Failure = Upstream.Failure

        /// The closure to execute on receipt of a value.
        final public let receiveValue: (Upstream.Output) -> Void

        /// The closure to execute on completion.
        final public let receiveCompletion: (Subscribers.Completion<Upstream.Failure>) -> Void

        /// A textual representation of this instance.
        ///
        /// Calling this property directly is discouraged. Instead, convert an
        /// instance of any type to a string by using the `String(describing:)`
        /// initializer. This initializer works with any type, and uses the custom
        /// `description` property for types that conform to
        /// `CustomStringConvertible`:
        ///
        ///     struct Point: CustomStringConvertible {
        ///         let x: Int, y: Int
        ///
        ///         var description: String {
        ///             return "(\(x), \(y))"
        ///         }
        ///     }
        ///
        ///     let p = Point(x: 21, y: 30)
        ///     let s = String(describing: p)
        ///     print(s)
        ///     // Prints "(21, 30)"
        ///
        /// The conversion of `p` to a string in the assignment to `s` uses the
        /// `Point` type's `description` property.
        final public var description: String { get }

        /// The custom mirror for this instance.
        ///
        /// If this type has value semantics, the mirror should be unaffected by
        /// subsequent mutations of the instance.
        final public var customMirror: Mirror { get }

        /// A custom playground description for this instance.
        final public var playgroundDescription: Any { get }

        /// Initializes a sink with the provided closures.
        ///
        /// - Parameters:
        ///   - receiveValue: The closure to execute on receipt of a value. If `nil`, the sink uses an empty closure.
        ///   - receiveCompletion: The closure to execute on completion. If `nil`, the sink uses an empty closure.
        public init(receiveCompletion: ((Subscribers.Completion<Subscribers.Sink<Upstream>.Failure>) -> Void)? = nil, receiveValue: @escaping ((Subscribers.Sink<Upstream>.Input) -> Void))

        /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
        ///
        /// Use the received `Subscription` to request items from the publisher.
        /// - Parameter subscription: A subscription that represents the connection between publisher and subscriber.
        final public func receive(subscription: Subscription)

        /// Tells the subscriber that the publisher has produced an element.
        ///
        /// - Parameter input: The published element.
        /// - Returns: A `Demand` instance indicating how many more elements the subcriber expects to receive.
        final public func receive(_ value: Subscribers.Sink<Upstream>.Input) -> Subscribers.Demand

        /// Tells the subscriber that the publisher has completed publishing, either normally or with an error.
        ///
        /// - Parameter completion: A `Completion` case indicating whether publishing completed normally or with an error.
        final public func receive(completion: Subscribers.Completion<Subscribers.Sink<Upstream>.Failure>)

        /// Cancel the activity.
        final public func cancel()
    }
}

extension Subscribers {

    /// A signal that a publisher doesn’t produce additional elements, either due to normal completion or an error.
    ///
    /// - finished: The publisher finished normally.
    /// - failure: The publisher stopped publishing due to the indicated error.
    public enum Completion<Failure> where Failure : Error {

        case finished

        case failure(Failure)
    }
}

extension Subscribers {

    /// A requested number of items, sent to a publisher from a subscriber via the subscription.
    ///
    /// - unlimited: A request for an unlimited number of items.
    /// - max: A request for a maximum number of items.
    public enum Demand : Equatable, Comparable {

        /// Requests as many values as the `Publisher` can produce.
        case unlimited

        /// Limits the maximum number of values.
        /// The `Publisher` may send fewer than the requested number.
        /// Negative values will result in a `fatalError`.
        case max(Int)

        /// When adding any value to .unlimited, the result is .unlimited.
        public static func + (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Subscribers.Demand

        /// A demand for no items.
        ///
        /// This is equivalent to `Demand.max(0)`.
        public static var none: Subscribers.Demand { get }

        /// When adding any value to .unlimited, the result is .unlimited.
        public static func += (lhs: inout Subscribers.Demand, rhs: Subscribers.Demand)

        /// When adding any value to .unlimited, the result is .unlimited.
        public static func + (lhs: Subscribers.Demand, rhs: Int) -> Subscribers.Demand

        /// When adding any value to .unlimited, the result is .unlimited.
        public static func += (lhs: inout Subscribers.Demand, rhs: Int)

        public static func * (lhs: Subscribers.Demand, rhs: Int) -> Subscribers.Demand

        public static func *= (lhs: inout Subscribers.Demand, rhs: Int)

        /// When subtracting any value (including .unlimited) from .unlimited, the result is still .unlimited. Subtracting unlimited from any value (except unlimited) results in .max(0). A negative demand is possible, but be aware that it is not usable when requesting values in a subscription.
        public static func - (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Subscribers.Demand

        /// When subtracting any value (including .unlimited) from .unlimited, the result is still .unlimited. Subtracting unlimited from any value (except unlimited) results in .max(0). A negative demand is possible, but be aware that it is not usable when requesting values in a subscription.
        public static func -= (lhs: inout Subscribers.Demand, rhs: Subscribers.Demand)

        /// When subtracting any value from .unlimited, the result is still .unlimited. A negative demand is possible, but be aware that it is not usable when requesting values in a subscription.
        public static func - (lhs: Subscribers.Demand, rhs: Int) -> Subscribers.Demand

        /// When subtracting any value from .unlimited, the result is still .unlimited. A negative demand is possible, but be aware that it is not usable when requesting values in a subscription.
        public static func -= (lhs: inout Subscribers.Demand, rhs: Int)

        public static func > (lhs: Subscribers.Demand, rhs: Int) -> Bool

        public static func >= (lhs: Subscribers.Demand, rhs: Int) -> Bool

        public static func > (lhs: Int, rhs: Subscribers.Demand) -> Bool

        public static func >= (lhs: Int, rhs: Subscribers.Demand) -> Bool

        public static func < (lhs: Subscribers.Demand, rhs: Int) -> Bool

        public static func < (lhs: Int, rhs: Subscribers.Demand) -> Bool

        public static func <= (lhs: Subscribers.Demand, rhs: Int) -> Bool

        public static func <= (lhs: Int, rhs: Subscribers.Demand) -> Bool

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool

        /// If lhs is .unlimited, then the result is always false. If rhs is .unlimited then the result is always false. Otherwise, the two max values are compared.
        public static func < (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool

        /// If lhs is .unlimited and rhs is .unlimited then the result is true. Otherwise, the rules for < are followed.
        public static func <= (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool

        /// Returns a Boolean value that indicates whether the value of the first
        /// argument is greater than or equal to that of the second argument.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func >= (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool

        /// If rhs is .unlimited, then the result is always false. If lhs is .unlimited then the result is always false. Otherwise, the two max values are compared.
        public static func > (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool

        /// Returns `true` if `lhs` and `rhs` are equal. `.unlimited` is not equal to any integer.
        public static func == (lhs: Subscribers.Demand, rhs: Int) -> Bool

        /// Returns `true` if `lhs` and `rhs` are not equal. `.unlimited` is not equal to any integer.
        public static func != (lhs: Subscribers.Demand, rhs: Int) -> Bool

        /// Returns `true` if `lhs` and `rhs` are equal. `.unlimited` is not equal to any integer.
        public static func == (lhs: Int, rhs: Subscribers.Demand) -> Bool

        /// Returns `true` if `lhs` and `rhs` are not equal. `.unlimited` is not equal to any integer.
        public static func != (lhs: Int, rhs: Subscribers.Demand) -> Bool

        /// Returns the number of requested values, or nil if unlimited.
        public var max: Int? { get }
    }
}

public protocol TopLevelDecoder {

    associatedtype Input

    func decode<T>(_ type: T.Type, from: Self.Input) throws -> T where T : Decodable
}

public protocol TopLevelEncoder {

    associatedtype Output

    func encode<T>(_ value: T) throws -> Self.Output where T : Encodable
}
