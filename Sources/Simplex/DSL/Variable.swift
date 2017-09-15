/// External variable that describes "constraints"
/// and "objective function" of linear programming.
public final class Variable: VariableProtocol
{
    /// Textual representation for debugging purpose.
    /// - Note: Can be empty.
    public let name: String

    public init(_ name: String = "")
    {
        self.name = name
    }

    internal var isExternal: Bool { return true }
}

extension Variable: Hashable
{
    public static func == (l: Variable, r: Variable) -> Bool
    {
        return l === r
    }

    public var hashValue: Int
    {
        return ObjectIdentifier(self).hashValue
    }
}

extension Variable: Comparable
{
    public static func < (l: Variable, r: Variable) -> Bool
    {
        return l.name < r.name
    }
}

extension Variable: CustomStringConvertible
{
    public var description: String
    {
        return self.name.isEmpty ? "_v\(self.hashValue % 100)" : self.name
    }
}

extension Variable: CustomDebugStringConvertible
{
    public var debugDescription: String
    {
        return "Variable(\(self.description))"
    }
}
