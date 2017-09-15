/// Optimal basic feasible solution to the `Problem`.
public struct Solution
{
    /// Optimal value for objective function that is either minimized or maximized.
    public let objective: Double

    /// Optimal values for variables.
    public let variables: [Variable: Double]

    public init(objective: Double, variables: [Variable: Double])
    {
        self.objective = objective
        self.variables = variables
    }
}

extension Solution: Equatable, NearlyEquatable
{
    public static func == (l: Solution, r: Solution) -> Bool
    {
        return l.isNearlyEqual(to: r)
    }

    internal func isNearlyEqual(to: Solution) -> Bool
    {
        guard self.objective.isNearlyEqual(to: to.objective) else { return false }
        guard self.variables.isNearlyEqual(to: to.variables) else { return false }
        return true
    }
}
