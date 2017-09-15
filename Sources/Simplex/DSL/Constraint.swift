/// Linear equality or inequality, e.g. `x1 + x2 <= 3`.
public final class Constraint
{
    public let leftExpression: Expression
    public let rightExpression: Expression
    public let comparisonOperator: ComparisonOperator

    public init(
        _ leftExpression: Expression,
        _ comparisonOperator: ComparisonOperator,
        _ rightExpression: Expression
        )
    {
        self.leftExpression = leftExpression
        self.rightExpression = rightExpression
        self.comparisonOperator = comparisonOperator
    }
}

extension Constraint
{
    public var rowInfo: Tableau.RowInfo
    {
        let rowInfo = Tableau.RowInfo(
            expression: self.leftExpression - self.rightExpression
        )
        return self.comparisonOperator == .lessThanOrEqual ? -rowInfo : rowInfo
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
        return "\(self.leftExpression) \(self.comparisonOperator.rawValue) \(self.rightExpression)"
    }
}

extension Constraint: CustomDebugStringConvertible
{
    public var debugDescription: String
    {
        return "Constraint(\(self.leftExpression.debugDescription) \(self.comparisonOperator.rawValue) \(self.rightExpression.debugDescription))"
    }
}

// MARK: Operator

public enum ComparisonOperator: String
{
    case equal = "="
    case greaterThanOrEqual = ">="
    case lessThanOrEqual = "<="

    public var inverted: ComparisonOperator
    {
        switch self {
        case .equal: return .equal
        case .greaterThanOrEqual: return .lessThanOrEqual
        case .lessThanOrEqual: return .greaterThanOrEqual
        }
    }
}
