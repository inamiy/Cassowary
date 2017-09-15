/// Objective function that will be either minimized or maximized.
public struct Objective
{
    public let goal: Goal
    public let expression: Expression

    public init(goal: Goal, expression: Expression)
    {
        self.goal = goal
        self.expression = expression
    }

    public static func minimize(_ expression: Expression) -> Objective
    {
        return .init(goal: .minimize, expression: expression)
    }

    public static func maximize(_ expression: Expression) -> Objective
    {
        return .init(goal: .maximize, expression: expression)
    }
}

extension Objective
{
    internal var rowInfo: Tableau.RowInfo
    {
        switch self.goal {
        case .minimize:
            return .init(expression: self.expression)
        case .maximize:
            return .init(expression: -self.expression)
        }
    }
}

extension Objective: CustomStringConvertible
{
    public var description: String
    {
        switch self.goal {
        case .minimize:
            return "Minimize \(self.expression)"
        case .maximize:
            return "Maximize \(self.expression)"
        }
    }
}

extension Objective: CustomDebugStringConvertible
{
    public var debugDescription: String
    {
        switch self.goal {
        case .minimize:
            return "Objective.minimize(\(self.expression.debugDescription))"
        case .maximize:
            return "Objective.maximize(\(self.expression.debugDescription))"
        }
    }
}

// MARK: Objective.Goal

extension Objective
{
    /// Either `.minimize` or `maximize`.
    public enum Goal
    {
        case minimize
        case maximize

        internal var isMinimize: Bool {
            switch self {
            case .minimize: return true
            case .maximize: return false
            }
        }
    }
}
