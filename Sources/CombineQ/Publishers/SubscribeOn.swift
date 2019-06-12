extension Publishers {
    
    /// A publisher that receives elements from an upstream publisher on a specific scheduler.
    public struct SubscribeOn<Upstream, Context> : Publisher where Upstream : Publisher, Context : Scheduler {
        
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The scheduler the publisher should use to receive elements.
        public let scheduler: Context
        
        /// Scheduler options that customize the delivery of elements.
        public let options: Context.SchedulerOptions?
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            let subscription = SubscribeOnSubscriptions(pub: self, sub: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Publishers.SubscribeOn {
    
    private final class SubscribeOnSubscriptions<S>:
        CustomSubscription<Publishers.SubscribeOn<Upstream, Context>, S>
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure
    {
        override func request(_ demand: Subscribers.Demand) {
            Global.Unimplemented()
            self.state.write { __state in
                switch __state {
                case .waiting:
                    guard demand > 0 else {
                        return
                    }
                    
                    let subscriber = AnySubscriber<Output, Failure>(
                        receiveSubscription: { (subscription) in
                            self.pub.scheduler.schedule {
                                subscription.request(demand)
                            }
                        },
                        receiveValue: { output in
                            return .max(0)
                        },
                        receiveCompletion: { completion in
                            
                        }
                    )

                    self.pub.subscribe(subscriber)
                case .subscribing(let currentDemand):
                    __state = .subscribing(currentDemand + demand)
                case .completed, .cancelled:
                    break
                }
                
            }
        }
        
        private func receive(subscription: Subscription) {
            Global.Unimplemented()
        }
        
        public func receive(_ value: Output) -> Subscribers.Demand {
            Global.Unimplemented()
        }
        
        override func cancel() {
            self.state.store(.cancelled)
        }
    }
}
