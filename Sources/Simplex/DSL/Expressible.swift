/// `Expression` convertible.
public protocol Expressible
{
    var expression: Expression { get }
}

extension Expression: Expressible
{
    public var expression: Expression
    {
        return self
    }
}

extension Variable: Expressible
{
    public var expression: Expression
    {
        return .variable(self)
    }
}
