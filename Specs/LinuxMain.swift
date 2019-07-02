import XCTest
import Quick

@testable import CombineXTests

QCKMain([
    AnyCancellableSpec.self,
    AnySubscriberSpec.self,
    CombineIdentifierSpec.self,
    DemandSpec.self,
    SubscriptionSpec.self,
    
    ConcatenateSpec.self,
    CountSpec.self,
    EmptySpec.self,
    FlatMapSpec.self,
    MapErrorSpec.self,
    MeasureIntervalSpec.self,
    MergeSpec.self,
    OptionalSpec.self,
    OutputSpec.self,
    PrintSpec.self,
    RemoveDuplicatesSpec.self,
    SequenceSpec.self,
    TryCompactMapSpec.self,
    TryDropWhileSpec.self,
    
    ImmediateSchedulerSpec.self,
    DispatchSchedulerSpec.self,
    
    PassthroughSubjectSpec.self,
    CurrentValueSubjectSpec.self,
    
    AssignSpec.self,
    SinkSpec.self,
])
