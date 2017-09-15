extension Tableau
{
    /// Simplex tableau column keys.
    public enum Column
    {
        case variable(Variable)
        case slackVariable(SlackVariable)
        case dummyVariable(DummyVariable)
        case artificialVariable(SlackVariable)

        public init?(row: Row)
        {
            switch row {
            case let .variable(variable):
                self = .variable(variable)
            case let .slackVariable(variable):
                self = .slackVariable(variable)
            case let .dummyVariable(variable):
                self = .dummyVariable(variable)
            case let .artificialVariable(variable):
                self = .artificialVariable(variable)
            case .objective,
                 .artificialObjective:
                return nil
            }
        }
    }
}

extension Tableau.Column
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

    private var _enumOrder: Int
    {
        switch self {
        case .variable: return 0
        case .slackVariable: return 1
        case .dummyVariable: return 2
        case .artificialVariable: return 3
        }
    }
}

extension Tableau.Column: Hashable
{
    public static func == (l: Tableau.Column, r: Tableau.Column) -> Bool
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
        case let .artificialVariable(variable):
            return _hash(self._enumOrder, variable)
        }
    }
}

extension Tableau.Column: Comparable
{
    public static func < (l: Tableau.Column, r: Tableau.Column) -> Bool
    {
        switch (l, r) {
        case let (.variable(l), .variable(r)):
            return l < r
        case let (.artificialVariable(l), .artificialVariable(r)):
            return l < r
        case let (.slackVariable(l), .slackVariable(r)):
            return l < r
        case let (.dummyVariable(l), .dummyVariable(r)):
            return l < r
        default:
            return l._enumOrder < r._enumOrder
        }
    }
}

extension Tableau.Column: CustomStringConvertible
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
        }
    }
}

extension Tableau.Column: VariableProtocol
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
        }
    }
}
