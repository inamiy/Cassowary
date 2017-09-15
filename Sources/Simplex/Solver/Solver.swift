/// Simplex solver.
public struct Solver
{
    public typealias Column = Tableau.Column
    public typealias Row = Tableau.Row
    public typealias RowInfo = Tableau.RowInfo

    /// Goal of solving tableau, i.e. `.minimize` or `.maximize`.
    public var goal: Objective.Goal

    /// Simplex tableau.
    public var tableau: Tableau

    /// Dictionary to map marker variable per constraint.
    public var markerVariables: [Constraint: Column] = [:]

    public private(set) var slackCounter: UInt = 0
    public private(set) var artificialCounter: UInt = 0
    public private(set) var dummyCounter: UInt = 0

    public private(set) var needsOptimize: Bool = false

    public init(problem: Problem) throws
    {
        self.goal = problem.objective.goal
        self.tableau = Tableau(columns: [:], rows: [:])

        self.tableau.insertRow(.objective, rowInfo: problem.objective.rowInfo)

        for constraint in problem.constraints  {
            try self.addConstraints(constraint)
        }

        // Automatically add non-negativity to all variables.
        if problem.allRestricted {
            let variables = self.tableau.rows.keys.flatMap { $0.variable } + self.tableau.columns.keys.flatMap { $0.variable }

            for variable in variables.sorted(by: <) {
                try self.addConstraints(variable >= 0.0)
            }
        }
    }

    // MARK: Add Constraints

    /// - Throws:
    ///   - `Error.addError(.constraintExists(constraint))`
    ///   - `Error.optimizeError(.infeasible)`
    ///   - `Error.optimizeError(.unbounded)`
    @discardableResult
    public mutating func addConstraints(_ constraints: Constraint...) throws -> [Constraint]
    {
        return try self.addConstraints(constraints)
    }

    /// - Throws:
    ///   - `Error.addError(.constraintExists(constraint))`
    ///   - `Error.optimizeError(.infeasible)`
    ///   - `Error.optimizeError(.unbounded)`
    @discardableResult
    public mutating func addConstraints(_ constraints: [Constraint]) throws -> [Constraint]
    {
        for constraint in constraints {
            try self.addConstraint(constraint)
        }
        return constraints
    }

    /// - Throws:
    ///   - `Error.addError(.constraintExists(constraint))`
    ///   - `Error.optimizeError(.infeasible)`
    ///   - `Error.optimizeError(.unbounded)`
    @discardableResult
    public mutating func addConstraint(_ constraint: Constraint) throws -> Constraint
    {
        guard self.markerVariables[constraint] == nil else {
            throw Error.addError(.constraintExists(constraint))
        }

        Debug.print()
        Debug.print("========================================")
        Debug.print("addConstraint: \(constraint)")

        let (rowInfo, markerColumn) = self._createRowInfo(constraint: constraint)

        Debug.printTableau(self.tableau, "slack added")

        try self.addRowInfo(rowInfo, candidates: [markerColumn])

        Debug.printTableau(self.tableau, "end addConstraint: \(constraint)")

        // Comment-Out: Optimizing per `addConstraint` will fail in simplex algorithm.
//        try self.optimize()

        return constraint
    }

    /// Create `rowInfo` from `constraint` with its variables replaced by basic variables
    /// in the `tableau` (so that `rowInfo` will contain non-basic variables only).
    /// After that, slack & dummy variables are added to `rowInfo`.
    private mutating func _createRowInfo(constraint: Constraint) -> (RowInfo, markerColumn: Column)
    {
        Debug.print("before createRowInfo")
        Debug.print("    constraint = \(constraint)")
        Debug.print("    constraint.rowInfo = \(constraint.rowInfo)")

        // Update `rowInfo` using current `tableau`.
        var newRowInfo = self.tableau.parametrizeRowInfo(constraint.rowInfo)

        let markerColumn: Column

        if constraint.comparisonOperator == .equal {
            // Add a dummy variable.
            let dummy = Column.dummyVariable(self.makeDummyVariable())
            newRowInfo.terms[dummy] = 1
            markerColumn = dummy
        }
        else {
            // Add a slack variable.
            let slack = Column.slackVariable(self.makeSlackVariable())
            newRowInfo.terms[slack] = -1
            markerColumn = slack
        }
        self.markerVariables[constraint] = markerColumn

        // Make constant positive.
        if newRowInfo.constant < 0 {
            newRowInfo *= -1
        }

        Debug.print("    final createRowInfo result = \(newRowInfo)")
        Debug.print()

        return (newRowInfo, markerColumn)
    }

    public mutating func makeSlackVariable() -> SlackVariable
    {
        self.slackCounter += 1
        return SlackVariable(label: "s\(self.slackCounter)")
    }

    public mutating func makeDummyVariable() -> DummyVariable
    {
        self.dummyCounter += 1
        return DummyVariable(label: "d\(self.dummyCounter)")
    }

    private mutating func _makeArtificialVariable() -> SlackVariable
    {
        self.artificialCounter += 1
        return SlackVariable(label: "a\(self.artificialCounter)")
    }

    /// Find a new basic variable from `rowInfo` that is either `isExternal` or `candidates`,
    /// then either add it to tableau directly or run two-phase simplex method.
    ///
    /// - Throws:
    ///   - `Error.optimizeError(.infeasible)`
    ///   - `Error.optimizeError(.unbounded)`
    public mutating func addRowInfo(_ rowInfo: RowInfo, candidates: [Column]) throws
    {
        Debug.print("addRowInfo = \(rowInfo), candidates = \(candidates)")

        if let basicColumn = try Solver.findBasicColumn(rowInfo: rowInfo, candidates: candidates) {
            Debug.print("===> findBasicColumn = \(basicColumn)")
            self._solveAndInsert(rowInfo: rowInfo, for: basicColumn)
        }
        else {
            Debug.print("===> Could not findBasicColumn")
            try self._solvePhase1Simplex(rowInfo: rowInfo)
        }

        self.needsOptimize = true
    }

    /// Solve `rowInfo` and insert `basicColumn = solvedRowInfo` directly into the tableau.
    private mutating func _solveAndInsert(rowInfo: RowInfo, for basicColumn: Column)
    {
        precondition(rowInfo.constant >= 0)

        Debug.print("===> before rowInfo.solve, rowInfo = \(rowInfo), basicColumn = \(basicColumn)")

        var rowInfo = rowInfo

        // NOTE:
        // Modified `rowInfo` will have basic feasible solved form,
        // e.g. `x3 = -1/3 * x1 + -2/3 * x2`.
        rowInfo.solve(column: basicColumn)

        Debug.print("===> after rowInfo.solve: \(basicColumn) = \(rowInfo), basicColumn = \(basicColumn)")

        // Substitute out all basic variables in current tableau.
        self.tableau._parametrizeRows(solvedColumn: basicColumn, solvedRowInfo: rowInfo)

        // Add row after substituting existing tableau is complete.
        self.tableau.insertRow(.init(column: basicColumn), rowInfo: rowInfo)
    }

    /// Add `rowInfo` as artificial row and solve Phase-1 Simplex.
    ///
    /// - Throws:
    ///   - `Error.optimizeError(.infeasible)`
    ///   - `Error.optimizeError(.unbounded)`
    private mutating func _solvePhase1Simplex(rowInfo: RowInfo) throws
    {
        precondition(rowInfo.constant >= 0)

        Debug.printTableau(self.tableau, "before Simplex Phase1, rowInfo = \(rowInfo)")
        defer {
            Debug.printTableau(self.tableau, "after Simplex Phase1")
            Debug.print()
        }

        let artificialColumn = Column.artificialVariable(self._makeArtificialVariable())
        let artificialRow = Row(column: artificialColumn)

        defer {
            self.tableau.removeRow(.artificialObjective)
            self.tableau.removeColumn(artificialColumn)
        }

        self.tableau.insertRow(.artificialObjective, rowInfo: rowInfo)
        self.tableau.insertRow(artificialRow, rowInfo: rowInfo)

        self.needsOptimize = true
        try self.optimize(objectiveRow: .artificialObjective)

        if !self.tableau.rows[.artificialObjective]!.constant.isNearlyEqual(to: 0) {
            Debug.printTableau(self.tableau, "AddError.infeasible")
            throw Error.optimizeError(.infeasible)
        }

        // If artificial variable is still chosen as basic,
        // exit it as non-basic & enter first `isPivotable` as basic.
        if let rowInfo = self.tableau.rows[artificialRow] {
            if let entryColumn = rowInfo.terms.keys.first(where: { $0.isPivotable }) {
                self.tableau.pivot(entryColumn: entryColumn, exitColumn: artificialColumn)
            }
        }
    }

    /// Find a preferred basic variable from `rowInfo`.
    ///
    /// - Note: `slackedRowInfo` doesn't get mutated if error is thrown.
    /// - Parameter candidates: Slack variables that can enter into basic variable.
    /// - Throws: `Error.optimizeError(.infeasible)`.
    public static func findBasicColumn(rowInfo: RowInfo, candidates: [Column]) throws -> Column?
    {
        if let basicColumn = rowInfo.findBasicColumn(candidates: candidates) {
            return basicColumn
        }

        // Check for slack & error variables.
        if rowInfo.terms.contains(where: { !$0.key.isDummy }) {
            return nil
        }

        // If `rowInfo` only contains dummy variables, feasible solution requires `constant = 0`.
        if let dummyColumn = rowInfo.terms.first(where: { $0.key.isDummy })?.key,
            rowInfo.constant.isNearlyEqual(to: 0)
        {
            return dummyColumn
        }
        else {
            throw Error.optimizeError(.infeasible)
        }
    }

    // MARK: Remove Constraints

    /// - Throws: `Error.removeError(.notFound(constraint))`
    public mutating func removeConstraints(_ constraints: Constraint...) throws
    {
        try self.removeConstraints(constraints)
    }

    /// - Throws: `Error.removeError(.notFound(constraint))`
    public mutating func removeConstraints(_ constraints: [Constraint]) throws
    {
        for constraint in constraints {
            try self.removeConstraint(constraint)
        }
    }

    /// - Throws: `Error.removeError(.notFound(constraint))`
    public mutating func removeConstraint(_ constraint: Constraint) throws
    {
        guard let markerColumn = self.markerVariables.removeValue(forKey: constraint) else {
            throw Error.removeError(.constraintNotFound(constraint))
        }

        self.needsOptimize = true

        if let rows = self.tableau.columns[markerColumn] {
            var exitRow: Row?
            var minRatio = 0.0

            // Look for negative coefficient first and find `minRatio`.
            for row in rows {
                if row.isRestricted,
                    let expr = self.tableau.rows[row],
                    let coeff = expr.terms[markerColumn],
                    coeff < 0.0
                {
                    let r = -expr.constant / coeff
                    if exitRow == nil || r < minRatio {
                        minRatio = r
                        exitRow = row
                    }
                }
            }

            // Look for positive coefficient and find `minRatio`.
            if exitRow == nil {
                for row in rows {
                    if row.isRestricted,
                        let expr = self.tableau.rows[row],
                        let coeff = expr.terms[markerColumn]
                    {
                        let r = expr.constant / coeff
                        if exitRow == nil || r < minRatio {
                            minRatio = r
                            exitRow = row
                        }
                    }
                }
            }

            if exitRow == nil {
                if rows.isEmpty {
                    self.tableau.removeColumn(markerColumn)
                }
                else {
                    exitRow = rows.first { $0 != .objective }
                }
            }

            if let exitRow = exitRow, let exitColumn = Column(row: exitRow) {
                self.tableau.pivot(entryColumn: markerColumn, exitColumn: exitColumn)
            }
        }

        let markerRow = Row(column: markerColumn)

        if self.tableau.rows.index(forKey: markerRow) != nil {
            self.tableau.removeRow(markerRow)
        }
    }

    // MARK: Solve

    /// `optimize` and `evaluateSolution`.
    /// - Throws: `Error.optimizeError(.unbounded)`
    @discardableResult
    public mutating func solve() throws -> Solution
    {
        try self.optimize()
        return self.evaluateSolution()
    }

    /// Keep pivoting until tableau is optimized.
    /// - Throws: `Error.optimizeError(.unbounded)`
    public mutating func optimize(objectiveRow: Row = .objective) throws
    {
        guard self.needsOptimize else { return }

        Debug.printTableau(self.tableau, "before optimize")
        defer {
            Debug.printTableau(self.tableau, "after optimize")
        }

        while true {
            guard let objectiveRowInfo = self.tableau.rows[objectiveRow] else { return }

            Debug.print("[optimize loop] objectiveRowInfo.terms = \(objectiveRowInfo.terms)")

            guard let (entryColumn, _) = objectiveRowInfo.terms
                .sorted(by: { $0.key < $1.key })
                .first(where: { column, coeff in
                    return column.isPivotable && coeff < 0 && !coeff.isNearlyEqual(to: 0)
                })
                else {
                    // Exit when all coefficients of pivotable variables are non-negative.
                    Debug.print("[optimize loop] Stop finding pivot")
                    break
                }

            var minRatio = Double.greatestFiniteMagnitude
            var exitRow: Row?

            Debug.printTableau(self.tableau, "[optimize loop] Find pivot start, entryColumn = \(entryColumn)")

            // Find pivot row with minimum ratio.
            if let rows = self.tableau.columns[entryColumn] {
                for row in rows where row.isPivotable {
                    let rowInfo = self.tableau.rows[row]!
                    let entryCoeff = rowInfo.terms[entryColumn, default: 0]
                    Debug.print("[optimize loop] check entryCoeff = \(entryCoeff) for row = \(row)")
                    if entryCoeff < 0 {
                        let ratio = -rowInfo.constant / entryCoeff
                        Debug.print("  [optimize loop] check ratio = \(ratio) for row = \(row)")

                        if ratio < minRatio {
                            minRatio = ratio
                            exitRow = row
                        }
                    }
                }
            }

            Debug.print("minRatio = \(minRatio), exitRow = \(String(describing: exitRow))")

            if let exitColumn = exitRow.flatMap(Column.init) {
                Debug.print("optimize to pivot: \(exitColumn) -> \(entryColumn)")
                self.tableau.pivot(entryColumn: entryColumn, exitColumn: exitColumn)
            }
            else {
                Debug.printTableau(self.tableau, "Error.optimizeError(.unbounded)")
                throw Error.optimizeError(.unbounded)
            }
        }

        self.needsOptimize = false
    }

    /// - Throws: `Error.optimizeError(.dualOptimizeFailed)`
    public mutating func dualOptimize(objectiveRow: Row = .objective) throws
    {
        Debug.printTableau(self.tableau, "before dualOptimize")
        defer {
            Debug.printTableau(self.tableau, "after dualOptimize")
        }

        let objectiveRowInfo = self.tableau.rows[objectiveRow]!

        while !self.tableau.infeasibleRows.isEmpty {
            let exitRow = self.tableau.infeasibleRows.removeFirst()
            let rowInfo = self.tableau.rows[exitRow]

            if let rowInfo = rowInfo, rowInfo.constant < 0 {
                var entryColumn: Column?
                var minRatio = Double.infinity

                for (column, coeff) in rowInfo.terms {
                    if coeff > 0 && column.isPivotable {
                        let objectiveCoeff = objectiveRowInfo.terms[column, default: 0]
                        let ratio = objectiveCoeff / coeff
                        if ratio < minRatio {
                            minRatio = ratio
                            entryColumn = column
                        }
                    }
                }

                if let entryColumn = entryColumn, let exitColumn = Column(row: exitRow) {
                    self.tableau.pivot(entryColumn: entryColumn, exitColumn: exitColumn)
                }
                else {
                    Debug.printTableau(self.tableau, "OptimizeError.dualOptimizeFailed")
                    throw Error.optimizeError(.dualOptimizeFailed)
                }
            }
        }
    }

    public func evaluateSolution() -> Solution
    {
        var variables = [Variable: Double]()

        for parametricColumn in self.tableau.externalParametricColumns {
            let row = Row(column: parametricColumn)
            if self.tableau.rows[row] != nil {
                continue
            }
            if case let .variable(variable) = row {
                variables[variable] = 0
            }
        }

        for basicRow in self.tableau.externalBasicRows {
            if case let .variable(variable) = basicRow, let rowInfo = self.tableau.rows[basicRow] {
                variables[variable] = rowInfo.constant
            }
        }

        let sign: Double = self.goal == .minimize ? 1 : -1
        let objective = sign * self.tableau.rows[.objective]!.constant

        return Solution(objective: objective, variables: variables)
    }

}

// MARK: CustomStringConvertible

extension Solver: CustomStringConvertible
{
    public var description: String
    {
        let rows = self.tableau.rows
            .map { "\(_leftPad("\($0.key)", length: 10)): \($0.value)" }
            .joined(separator: "\n")

        return """
        [Tableau] Goal: \(goal), Columns: \(Array(tableau.columns.keys.sorted(by: <)))
          Rows:
        \(rows)
        """
    }
}
