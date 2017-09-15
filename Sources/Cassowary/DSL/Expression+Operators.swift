import Simplex

// MARK: Prefix Operators

public prefix func - <E: Expressible>(expr: E) -> Expression
{
    return .multiply(-1, expr.expression)
}

// MARK: Infix Operators

// MARK: `+`

public func + <E: Expressible, E2: Expressible>(l: E, r: E2) -> Expression
{
    return .add(l.expression, r.expression)
}

public func + <E: Expressible, N: DoubleConvertible>(l: E, r: N) -> Expression
{
    return .add(l.expression, .constant(r.double))
}

public func + <E: Expressible, N: DoubleConvertible>(l: N, r: E) -> Expression
{
    return .add(.constant(l.double), r.expression)
}

// MARK: `-`

public func - <E: Expressible, E2: Expressible>(l: E, r: E2) -> Expression
{
    return .add(l.expression, -r.expression)
}

public func - <E: Expressible, N: DoubleConvertible>(l: E, r: N) -> Expression
{
    return .add(l.expression, .constant(-r.double))
}

public func - <E: Expressible, N: DoubleConvertible>(l: N, r: E) -> Expression
{
    return .add(.constant(l.double), -r.expression)
}

// MARK: `*`

public func * <E: Expressible, N: DoubleConvertible>(l: E, r: N) -> Expression
{
    return .multiply(r.double, l.expression)
}

public func * <E: Expressible, N: DoubleConvertible>(l: N, r: E) -> Expression
{
    return .multiply(l.double, r.expression)
}

// MARK: `/`

public func / <E: Expressible, N: DoubleConvertible>(l: E, r: N) -> Expression
{
    precondition(r.double != 0, "Can't divide by 0.")
    return .multiply(1.0 / r.double, l.expression)
}
