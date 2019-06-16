/// A protocol that provides a scheduler with an expression for relative time.
public protocol SchedulerTimeIntervalConvertible {
    
    static func seconds(_ s: Int) -> Self
    
    static func seconds(_ s: Double) -> Self
    
    static func milliseconds(_ ms: Int) -> Self
    
    static func microseconds(_ us: Int) -> Self
    
    static func nanoseconds(_ ns: Int) -> Self
}
