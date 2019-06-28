import XCTest
import Quick

@testable import CombineXTests

QCKMain([
    AnyCancellableSpec.self,
    AnySubscriberSpec.self,
    CombineIdentifierSpec.self,
    DemandSpec.self,
    SubscriptionSpec.self,
    
    CompactMapSpec.self,
    CountSpec.self,
    EmptySpec.self,
    FilterSpec.self,
    FlatMapSpec.self,
    JustSpec.self,
    MapSpec.self,
    MeasureIntervalSpec.self,
    MergeSpec.self,
    OnceSpec.self,
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
