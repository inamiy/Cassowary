// MARK: Infix Operators

// MARK: `==`

public func == <E: Expressible, E2: Expressible>(l: E, r: E2) -> Constraint
{
    return Constraint(l.expression, .equal, r.expression)
}

public func == <E: Expressible, N: DoubleConvertible>(l: E, r: N) -> Constraint
{
    return Constraint(l.expression, .equal, .constant(r.double))
}

public func == <E: Expressible, N: DoubleConvertible>(l: N, r: E) -> Constraint
{
    return Constraint(.constant(l.double), .equal, r.expression)
}

// MARK: `>=`

public func >= <E: Expressible, E2: Expressible>(l: E, r: E2) -> Constraint
{
    return Constraint(l.expression, .greaterThanOrEqual, r.expression)
}

public func >= <E: Expressible, N: DoubleConvertible>(l: E, r: N) -> Constraint
{
    return Constraint(l.expression, .greaterThanOrEqual, .constant(r.double))
}

public func >= <E: Expressible, N: DoubleConvertible>(l: N, r: E) -> Constraint
{
    return Constraint(.constant(l.double), .greaterThanOrEqual, r.expression)
}

// MARK: `<=`

public func <= <E: Expressible, E2: Expressible>(l: E, r: E2) -> Constraint
{
    return Constraint(l.expression, .lessThanOrEqual, r.expression)
}

public func <= <E: Expressible, N: DoubleConvertible>(l: E, r: N) -> Constraint
{
    return Constraint(l.expression, .lessThanOrEqual, .constant(r.double))
}

public func <= <E: Expressible, N: DoubleConvertible>(l: N, r: E) -> Constraint
{
    return Constraint(.constant(l.double), .lessThanOrEqual, r.expression)
}
