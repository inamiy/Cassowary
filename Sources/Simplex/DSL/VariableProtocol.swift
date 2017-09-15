internal protocol VariableProtocol: Hashable
{
    /// Flag to exclude from entering basic variable.
    var isDummy: Bool { get }

    /// Flag that variable is known outside of the solver
    /// so that solver needs to solve its optimal value.
    var isExternal: Bool { get }

    /// Flag to enter into or exit from basic variables.
    var isPivotable: Bool { get }

    /// Flag to restrict variable as non-negative.
    var isRestricted: Bool { get }
}

extension VariableProtocol
{
    public var isDummy: Bool { return false }
    public var isExternal: Bool { return false }
    public var isPivotable: Bool { return false }
    public var isRestricted: Bool { return false }
}
