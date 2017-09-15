/// Linear programming problem type.
/// - Note: `Variable`s in `constraints` can be negative (See `allRestricted`).
public struct Problem
{
    /// Objective function.
    public let objective: Objective

    /// Array of linear equality or inequality.
    public let constraints: [Constraint]

    /// Flag for all variables in `constraints` to be restricted (non-negative).
    /// If `true`, `x >= 0` constraint(s) will be added in `Tableau.init` automatically.
    public let allRestricted: Bool

    /// Minimizing problem.
    public init(minimize expr: Expression, constraints: Constraint..., allRestricted: Bool = false)
    {
        self.init(objective: .minimize(expr), constraints: constraints, allRestricted: allRestricted)
    }

    /// Maximizing problem.
    public init(maximize expr: Expression, constraints: Constraint..., allRestricted: Bool = false)
    {
        self.init(objective: .maximize(expr), constraints: constraints, allRestricted: allRestricted)
    }

    public init(objective: Objective, constraints: Constraint..., allRestricted: Bool = false)
    {
        self.init(objective: objective, constraints: constraints, allRestricted: allRestricted)
    }

    public init(objective: Objective, constraints: [Constraint], allRestricted: Bool = false)
    {
        self.objective = objective
        self.constraints = constraints
        self.allRestricted = allRestricted
    }

    public func solve() throws -> Solution
    {
        var solver = try Solver(problem: self)
        let solution = try solver.solve()
        return solution
    }
}

extension Problem: CustomStringConvertible
{
    public var description: String
    {
        var description = ""
        description += "\(objective)\n"
        description += "Constraints:\n"
        description += constraints.map { "  \($0)" }.joined(separator: "\n")
        return description
    }
}

extension Problem: CustomDebugStringConvertible
{
    public var debugDescription: String
    {
        return "Problem(objective: \(objective.debugDescription), constraints: \(constraints.debugDescription))"
    }
}
