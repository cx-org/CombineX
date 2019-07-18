import XCTest
import Quick

@testable import CombineXTests

QCKMain([
    AnyCancellableSpec.self,
    AnySubscriberSpec.self,
    CombineIdentifierSpec.self,
    DemandSpec.self,
    
    AssertNoFailureSpec.self,
    BreakPointSpec.self,
    BufferSpec.self,
    CollectByCountSpec.self,
    ConcatenateSpec.self,
    DropUntilOutputSpec.self,
    EmptySpec.self,
    FlatMapSpec.self,
    JustSpec.self,
    MapErrorSpec.self,
    MeasureIntervalSpec.self,
    MergeSpec.self,
    OptionalSpec.self,
    OutputSpec.self,
    PrefixUntilOutputSpec.self,
    PrintSpec.self,
    RemoveDuplicatesSpec.self,
    ReplaceErrorSpec.self,
    ReplaceEmptySpec.self,
    ResultSpec.self,
    SequenceSpec.self,
    TryAllSatisfySpec.self,
    TryCatchSpec.self,
    TryCompactMapSpec.self,
    TryDropWhileSpec.self,
    TryPrefixWhileSpec.self,
    TryReduceSpec.self,
    TryRemoveDuplicatesSpec.self,
    TryScanSpec.self,
    
    ImmediateSchedulerSpec.self,
    
    PassthroughSubjectSpec.self,
    CurrentValueSubjectSpec.self,
    
    AssignSpec.self,
    SinkSpec.self,
])
