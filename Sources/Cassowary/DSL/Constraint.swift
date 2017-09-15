import Simplex

/// Linear equality or inequality with `priority` support,
/// e.g. `x1 + x2 <= 3 ~ .high`.
public final class Constraint
{
    /// Underlying `Simplex.Constraint`.
    public let raw: Simplex.Constraint

    /// Strength of the constraint.
    public let priority: Priority

    public init(raw: Simplex.Constraint, priority: Priority)
    {
        self.raw = raw
        self.priority = priority
    }
}

extension Constraint: Hashable
{
    public static func == (l: Constraint, r: Constraint) -> Bool
    {
        return l === r
    }

    public var hashValue: Int
    {
        return ObjectIdentifier(self).hashValue
    }
}

extension Constraint: Comparable
{
    public static func < (l: Constraint, r: Constraint) -> Bool
    {
        return l.hashValue < r.hashValue
    }
}

extension Constraint: CustomStringConvertible
{
    public var description: String
    {
        return "\(self.raw.leftExpression) \(self.raw.comparisonOperator.rawValue) \(self.raw.rightExpression)"
    }
}

extension Constraint: CustomDebugStringConvertible
{
    public var debugDescription: String
    {
        return "Constraint(\(self.raw.leftExpression.debugDescription) \(self.raw.comparisonOperator.rawValue) \(self.raw.rightExpression.debugDescription))"
    }
}
