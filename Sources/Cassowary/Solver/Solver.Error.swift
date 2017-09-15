import Simplex

// MARK: Solver.Error

extension Solver
{
    public enum Error: Swift.Error
    {
        case addError(AddError)
        case removeError(RemoveError)
        case optimizeError(OptimizeError)
        case editError(EditError)
    }
}

extension Solver.Error: Equatable
{
    public static func == (l: Solver.Error, r: Solver.Error) -> Bool
    {
        switch (l, r) {
        case let (.addError(l), .addError(r)):
            return l == r
        case let (.removeError(l), .removeError(r)):
            return l == r
        case let (.optimizeError(l), .optimizeError(r)):
            return l == r
        case let (.editError(l), .editError(r)):
            return l == r
        default:
            return false
        }
    }
}

// MARK: Solver.Error.AddError

extension Solver.Error
{
    public enum AddError: Swift.Error
    {
        /// Constraint already exists.
        case constraintExists(Constraint)

        /// Stay variable already exists.
        case stayVariableExists(Variable)

        /// Edit variable already exists.
        case editVariableExists(Variable)
    }
}

extension Solver.Error.AddError: Equatable
{
    public static func == (l: Solver.Error.AddError, r: Solver.Error.AddError) -> Bool
    {
        switch (l, r) {
        case let (.constraintExists(l), .constraintExists(r)):
            return l == r
        case let (.stayVariableExists(l), .stayVariableExists(r)):
            return l == r
        case let (.editVariableExists(l), .editVariableExists(r)):
            return l == r
        default:
            return false
        }
    }
}

// MARK: Solver.Error.RemoveError

extension Solver.Error
{
    public enum RemoveError: Swift.Error
    {
        /// Constraint not found.
        case constraintNotFound(Constraint)
    }
}

extension Solver.Error.RemoveError: Equatable
{
    public static func == (l: Solver.Error.RemoveError, r: Solver.Error.RemoveError) -> Bool
    {
        switch (l, r) {
        case let (.constraintNotFound(l), .constraintNotFound(r)):
            return l == r
        }
    }
}

// MARK: Solver.Error.OptimizeError

extension Solver.Error
{
    public enum OptimizeError: Swift.Error
    {
        /// No solution. Unsatisfiable.
        /// - Note: This occurs when `findBasicColumn(rowInfo:)` or `_solvePhase1Simplex`.
        case infeasible

        /// Solution has infinite possibiliies.
        /// - Note: This occurs during `optimize` (pivoting).
        case unbounded

        /// Solving dual problem was infeasible
        /// (i.e. Primary problem is either unbounded or infeasible).
        /// - Note: This occurs when `dualOptimize`.
        case dualOptimizeFailed
    }
}

extension Solver.Error.OptimizeError: Equatable
{
    public static func == (l: Solver.Error.OptimizeError, r: Solver.Error.OptimizeError) -> Bool
    {
        switch (l, r) {
        case (.infeasible, .infeasible):
            return true
        case (.unbounded, .unbounded):
            return true
        case (.dualOptimizeFailed, .dualOptimizeFailed):
            return true
        default:
            return false
        }
    }
}

// MARK: Solver.Error.EditError

extension Solver.Error
{
    public enum EditError: Swift.Error
    {
        /// Edit variable not found while `suggestValue`.
        case editVariableNotFound(Variable, suggestedValue: Double)
    }
}

extension Solver.Error.EditError: Equatable
{
    public static func == (l: Solver.Error.EditError, r: Solver.Error.EditError) -> Bool
    {
        switch (l, r) {
        case let (.editVariableNotFound(l), .editVariableNotFound(r)):
            return l == r
        }
    }
}
