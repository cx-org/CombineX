import CXShim
import CXUtility

public class TestTimeline<Context: Scheduler>: CustomStringConvertible {
    
    public class var tolerance: Context.SchedulerTimeType.Stride {
        return .seconds(0.01)
    }
    
    private let context: Context
    private let _records: LockedAtomic<[Context.SchedulerTimeType]>
    
    private init(context: Context, records: [Context.SchedulerTimeType]) {
        self.context = context
        self._records = LockedAtomic(records)
    }
    
    public convenience init(context: Context) {
        self.init(context: context, records: [])
    }
    
    public var records: [Context.SchedulerTimeType] {
        return self._records.load()
    }
    
    public func record() {
        self._records.withLockMutating {
            $0.append(self.context.now)
        }
    }
    
    public var description: String {
        return self.records.description
    }
}

public extension TestTimeline {
    
    func delayed(_ interval: Context.SchedulerTimeType.Stride) -> TestTimeline {
        return .init(
            context: self.context,
            records: self.records
                .map {
                    $0.advanced(by: interval)
                }
        )
    }
    
    func isCloseTo(to other: TestTimeline, tolerance: Context.SchedulerTimeType.Stride = TestTimeline.tolerance) -> Bool {
        let recordsA = self.records
        let recordsB = other.records
        
        guard recordsA.count == recordsB.count else {
            return false
        }
        for (a, b) in zip(recordsA, recordsB) {
            if Swift.abs(a.distance(to: b)) > tolerance {
                return false
            }
        }
        return true
    }
}
