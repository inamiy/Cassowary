/// AST of constants, variables, and linear operators.
public indirect enum Expression
{
    case variable(Variable)
    case constant(Double)
    case multiply(Double, Expression)
    case add(Expression, Expression)
}

extension Expression
{
    fileprivate var isAdd: Bool
    {
        switch self {
        case .add:
            return true
        case .variable, .constant, .multiply:
            return false
        }
    }
}

extension Expression: Hashable
{
    public static func == (l: Expression, r: Expression) -> Bool
    {
        switch (l, r) {
        case let (.variable(l), .variable(r)):
            return l == r
        case let (.constant(l), .constant(r)):
            return l == r
        case let (.multiply(l), .multiply(r)):
            return l == r
        case let (.add(l), .add(r)):
            return l == r
        default:
            return false
        }
    }

    public var hashValue: Int
    {
        switch self {
        case let .variable(variable):
            return _hash(variable, 0)
        case let .constant(value):
            return _hash(value, 1)
        case let .multiply(coeff, expr):
            return _hash(coeff, _hash(expr, 2))
        case let .add(expr1, expr2):
            return _hash(expr1, _hash(expr2, 3))
        }
    }
}

extension Expression: CustomStringConvertible
{
    public var description: String
    {
        switch self {
        case let .variable(variable):
            return variable.description
        case let .constant(value):
            return "\(value)"
        case let .multiply(coeff, expr):
            return coeff == 0 ? "\(expr)"
                : expr.isAdd ? "\(coeff) * (\(expr))"
                : "\(coeff) * \(expr)"
        case let .add(expr1, expr2):
            return "\(expr1) + \(expr2)"
        }
    }
}

extension Expression: CustomDebugStringConvertible
{
    public var debugDescription: String
    {
        switch self {
        case let .variable(variable):
            return "Expression(\(variable.debugDescription))"
        case let .constant(value):
            return "Expression(\(value))"
        case let .multiply(coeff, expr):
            return coeff == 0 ? expr.debugDescription : "Expression(\(coeff) * \(expr.debugDescription))"
        case let .add(expr1, expr2):
            return "Expression(\(expr1.debugDescription) + \(expr2.debugDescription))"
        }
    }
}

extension Expression: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral
{
    public init(floatLiteral value: Double)
    {
        self = .constant(value)
    }

    public init(integerLiteral value: Int)
    {
        self = .constant(Double(value))
    }
}
