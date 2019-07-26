#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class Timeline<Context: Scheduler>: CustomStringConvertible {
    
    class var tolerance: Context.SchedulerTimeType.Stride {
        return .seconds(0.01)
    }
    
    private let context: Context
    private let _records: Atom<[Context.SchedulerTimeType]>
    
    private init(context: Context, records: [Context.SchedulerTimeType]) {
        self.context = context
        self._records = Atom(val: records)
    }
    
    convenience init(context: Context) {
        self.init(context: context, records: [])
    }
    
    var records: [Context.SchedulerTimeType] {
        return self._records.get()
    }
    
    func record() {
        self._records.withLockMutating {
            $0.append(self.context.now)
        }
    }
    
    var description: String {
        return self.records.description
    }
}

extension Timeline {
    
    func delayed(_ interval: Context.SchedulerTimeType.Stride) -> Timeline {
        return .init(
            context: self.context,
            records: self.records
                .map {
                    $0.advanced(by: interval)
                }
        )
    }
    
    func isCloseTo(to other: Timeline, tolerance: Context.SchedulerTimeType.Stride = Timeline.tolerance) -> Bool {
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
