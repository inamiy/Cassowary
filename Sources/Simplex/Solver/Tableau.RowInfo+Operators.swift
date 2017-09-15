// MARK: Prefix Operators

internal prefix func - (rowInfo: Tableau.RowInfo) -> Tableau.RowInfo
{
    return -1.0 * rowInfo
}

// MARK: Infix Operators

internal func + (l: Tableau.RowInfo, r: Tableau.RowInfo) -> Tableau.RowInfo
{
    var l = l
    l += r
    return l
}

internal func - (l: Tableau.RowInfo, r: Tableau.RowInfo) -> Tableau.RowInfo
{
    return l + (-1 * r)
}

internal func * (multiplier: Double, rowInfo: Tableau.RowInfo) -> Tableau.RowInfo
{
    var rowInfo = rowInfo
    rowInfo *= multiplier
    return rowInfo
}

internal func += (l: inout Tableau.RowInfo, r: Tableau.RowInfo)
{
    l.terms.merge(r.terms, uniquingKeysWith: +)
    l.constant += r.constant
}

public func *= (rowInfo: inout Tableau.RowInfo, multiplier: Double)
{
    for (row, coeff) in rowInfo.terms {
        rowInfo.terms[row] = coeff * multiplier
    }
    rowInfo.constant *= multiplier
}
