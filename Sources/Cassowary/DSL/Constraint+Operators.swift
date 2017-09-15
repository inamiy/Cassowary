import Simplex

infix operator ~ : LogicalConjunctionPrecedence

/// Add priority to `Constraint`.
public func ~ (l: Constraint, r: Priority) -> Constraint
{
    return Constraint(raw: l.raw, priority: r)
}

// MARK: Infix Operators

// MARK: `==`

public func == <E: Expressible, E2: Expressible>(l: E, r: E2) -> Constraint
{
    return Constraint(raw: l == r, priority: .required)
}

public func == <E: Expressible, N: DoubleConvertible>(l: E, r: N) -> Constraint
{
    return Constraint(raw: l == r, priority: .required)
}

public func == <E: Expressible, N: DoubleConvertible>(l: N, r: E) -> Constraint
{
    return Constraint(raw: l == r, priority: .required)
}

// MARK: `>=`

public func >= <E: Expressible, E2: Expressible>(l: E, r: E2) -> Constraint
{
    return Constraint(raw: l >= r, priority: .required)
}

public func >= <E: Expressible, N: DoubleConvertible>(l: E, r: N) -> Constraint
{
    return Constraint(raw: l >= r, priority: .required)
}

public func >= <E: Expressible, N: DoubleConvertible>(l: N, r: E) -> Constraint
{
    return Constraint(raw: l >= r, priority: .required)
}

// MARK: `<=`

public func <= <E: Expressible, E2: Expressible>(l: E, r: E2) -> Constraint
{
    return Constraint(raw: l <= r, priority: .required)
}

public func <= <E: Expressible, N: DoubleConvertible>(l: E, r: N) -> Constraint
{
    return Constraint(raw: l <= r, priority: .required)
}

public func <= <E: Expressible, N: DoubleConvertible>(l: N, r: E) -> Constraint
{
    return Constraint(raw: l <= r, priority: .required)
}
