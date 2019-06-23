import XCTest
import Quick

@testable import CombineXTests

QCKMain([
    AnyCancellableSpec.self,
    AnySubscriberSpec.self,
    AssignSpec.self,
    CombineIdentifierSpec.self,
    CompactMapSpec.self,
    CurrentValueSubjectSpec.self,
    DemandSpec.self,
    EmptySpec.self,
    FlatMapSpec.self,
    JustSpec.self,
    MapSpec.self,
    MergeSpec.self,
    OnceSpec.self,
    PassthroughSubjectSpec.self,
    SinkSpec.self,
    SequenceSpec.self,
    SubscriptionSpec.self,
])
