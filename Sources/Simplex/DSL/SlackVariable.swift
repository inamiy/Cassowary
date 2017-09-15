/// Adjusted variable for inequality constraint.
/// - Note: This is used for artificial variable and error variable.
public typealias SlackVariable = _SlackVariable<_Slack>

/// Variable used to identify constraint in mixed-up simplex tableau.
public typealias DummyVariable = _SlackVariable<_Dummy>

/// Phantom type for slack, artificial, dummy variables.
public struct _SlackVariable<T: SlackProtocol>: VariableProtocol
{
    /// Textual representation for debugging purpose.
    /// - Warning: Can't be empty & must have unique label.
    public let label: String

    public init(label: String)
    {
        self.label = label
    }
}

extension _SlackVariable: Hashable
{
    public static func == (l: _SlackVariable, r: _SlackVariable) -> Bool
    {
        return l.label == r.label
    }

    public var hashValue: Int
    {
        return self.label.hashValue
    }
}

extension _SlackVariable: Comparable
{
    public static func < (l: _SlackVariable, r: _SlackVariable) -> Bool
    {
        return l.label < r.label
    }
}

extension _SlackVariable: CustomStringConvertible
{
    public var description: String
    {
        return self.label
    }
}

// MARK: SlackProtocol

public protocol SlackProtocol {}

public enum _Slack: SlackProtocol {}
public enum _Dummy: SlackProtocol {}

extension _SlackVariable where T == _Slack
{
    public var isPivotable: Bool { return true }
    public var isRestricted: Bool { return true }
}

extension _SlackVariable where T == _Dummy
{
    public var isDummy: Bool { return true }
    public var isRestricted: Bool { return true }
}
