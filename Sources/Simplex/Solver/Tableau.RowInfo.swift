extension Tableau
{
    /// Container of `terms` and `constant` that is converted from `Expression` AST.
    public struct RowInfo
    {
        public var terms: [Tableau.Column: Double]
        public var constant: Double

        public init(terms: [Tableau.Column: Double] = [:], constant: Double = 0)
        {
            self.terms = terms
            self.constant = constant
        }

        public init(expression: Expression)
        {
            switch expression {
            case let .variable(variable):
                self = .init(terms: [.variable(variable): 1])
            case let .constant(value):
                self = .init(constant: value)
            case let .multiply(coeff, expr):
                let rowInfo = RowInfo(expression: expr)
                self = .init(
                    terms: rowInfo.terms.mapValues { $0 * coeff },
                    constant: rowInfo.constant * coeff
                )
            case let .add(expr1, expr2):
                let rowInfo1 = RowInfo(expression: expr1)
                let rowInfo2 = RowInfo(expression: expr2)
                self = .init(
                    terms: rowInfo1.terms.merging(rowInfo2.terms, uniquingKeysWith: +),
                    constant: rowInfo1.constant + rowInfo2.constant
                )
            }
        }

        /// Find a preferred basic variable from `rowInfo`.
        ///
        /// - Parameter candidates:
        ///   Slack variables that can enter into basic variable.
        public func findBasicColumn(candidates: [Column]) -> Column?
        {
            for (column, _) in self.terms {
                if column.isExternal {
                    return column
                }
            }

            for candidate in candidates {
                if case .slackVariable = candidate  {
                    if self.terms[candidate, default: 0] < 0 {
                        return candidate
                    }
                }
            }

            return nil
        }

        /// Solve for `column` variable by modifying rowInfo's `column` to be zero
        /// and divide whole rowInfo by "its coefficient * `-1`".
        ///
        /// For example, if `self.terms = [x1: 1, x2: 2, x3: 3]` and `column = x3`,
        /// modified `self.terms` will have `[x1: -1/3, x2: -2/3]`
        /// which is a *basic feasible solved form*: `x3 = -1/3 * x1 + -2/3 * x2`.
        ///
        /// - Returns: Reciprocal of (previous) column's coefficient.
        @discardableResult
        public mutating func solve(column: Column) -> Double
        {
            let coeff = self.terms.removeValue(forKey: column)!
            let reciprocal = 1.0 / coeff
            self *= -reciprocal
            return reciprocal
        }

    }
}

extension Tableau.RowInfo: CustomStringConvertible
{
    public var description: String
    {
        let terms = self.terms
            .sorted(by: { $0.key < $1.key })
            .map { key, value -> String in
                value.isNearlyEqual(to: 1) ? "\(key)"
                    : value.isNearlyEqual(to: -1) ? "-\(key)"
                    : "\(_shortString(value))*\(key)"
            }
            .joined(separator: " + ")
        let constant = _shortString(self.constant)
        let expr =  terms.isEmpty ? "\(constant)"
            : self.constant.isNearlyEqual(to: 0) ? "\(terms)"
            : "\(constant) + \(terms)"
        return expr.replacingOccurrences(of: "+ -", with: "- ")
    }
}
