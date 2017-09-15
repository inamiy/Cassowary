extension Tableau
{
    /// Simplex tableau row keys.
    public enum Row
    {
        case variable(Variable)
        case slackVariable(SlackVariable)
        case dummyVariable(DummyVariable)
        case artificialVariable(SlackVariable)
        case objective
        case artificialObjective

        public init(column: Column)
        {
            switch column {
            case let .variable(variable):
                self = .variable(variable)
            case let .slackVariable(variable):
                self = .slackVariable(variable)
            case let .dummyVariable(variable):
                self = .dummyVariable(variable)
            case let .artificialVariable(variable):
                self = .artificialVariable(variable)
            }
        }
    }
}

extension Tableau.Row
{
    public var variable: Variable?
    {
        switch self {
        case let .variable(variable):
            return variable
        default:
            return nil
        }
    }
}

extension Tableau.Row: Hashable
{
    public static func == (l: Tableau.Row, r: Tableau.Row) -> Bool
    {
        switch (l, r) {
        case let (.variable(l), .variable(r)):
            return l == r
        case let (.slackVariable(l), .slackVariable(r)):
            return l == r
        case let (.dummyVariable(l), .dummyVariable(r)):
            return l == r
        case let (.artificialVariable(l), .artificialVariable(r)):
            return l == r
        case (.objective, .objective):
            return true
        case (.artificialObjective, .artificialObjective):
            return true
        default:
            return false
        }
    }

    public var hashValue: Int
    {
        switch self {
        case let .variable(variable):
            return _hash(self._enumOrder, variable)
        case let .slackVariable(variable):
            return _hash(self._enumOrder, variable)
        case let .dummyVariable(variable):
            return _hash(self._enumOrder, variable)
        case let (.artificialVariable(variable)):
            return _hash(self._enumOrder, variable)
        case .objective:
            return self._enumOrder
        case .artificialObjective:
            return self._enumOrder
        }
    }
}

extension Tableau.Row: Comparable
{
    public static func < (l: Tableau.Row, r: Tableau.Row) -> Bool
    {
        return l._enumOrder < r._enumOrder
    }
}

extension Tableau.Row
{
    private var _enumOrder: Int
    {
        switch self {
        case .variable: return 0
        case .slackVariable: return 1
        case .dummyVariable: return 2
        case .artificialVariable: return 3
        case .objective: return 4
        case .artificialObjective: return 5
        }
    }
}

extension Tableau.Row: CustomStringConvertible
{
    public var description: String
    {
        switch self {
        case let .variable(variable):
            return variable.description
        case let .slackVariable(variable):
            return variable.description
        case let .dummyVariable(variable):
            return variable.description
        case let .artificialVariable(variable):
            return variable.description
        case .objective:
            return "_obj"
        case .artificialObjective:
            return "_a_obj"
        }
    }
}

extension Tableau.Row: VariableProtocol
{
    public var isDummy: Bool
    {
        switch self {
        case let .variable(variable):
            return variable.isDummy
        case let .slackVariable(variable):
            return variable.isDummy
        case let .dummyVariable(variable):
            return variable.isDummy
        case let .artificialVariable(variable):
            return variable.isDummy
        case .objective,
             .artificialObjective:
            return false
        }
    }

    public var isExternal: Bool
    {
        switch self {
        case let .variable(variable):
            return variable.isExternal
        case let .slackVariable(variable):
            return variable.isExternal
        case let .dummyVariable(variable):
            return variable.isExternal
        case let .artificialVariable(variable):
            return variable.isExternal
        case .objective,
             .artificialObjective:
            return false
        }
    }

    public var isPivotable: Bool
    {
        switch self {
        case let .variable(variable):
            return variable.isPivotable
        case let .slackVariable(variable):
            return variable.isPivotable
        case let .dummyVariable(variable):
            return variable.isPivotable
        case let .artificialVariable(variable):
            return variable.isPivotable
        case .objective,
             .artificialObjective:
            return false
        }
    }

    public var isRestricted: Bool
    {
        switch self {
        case let .variable(variable):
            return variable.isRestricted
        case let .slackVariable(variable):
            return variable.isRestricted
        case let .dummyVariable(variable):
            return variable.isRestricted
        case let .artificialVariable(variable):
            return variable.isRestricted
        case .objective,
             .artificialObjective:
            return false
        }
    }
}
