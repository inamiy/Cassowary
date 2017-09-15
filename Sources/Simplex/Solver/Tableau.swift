/// Simplex tableau.
public struct Tableau
{
    /// Tableau columns with indexed non-zero rows.
    public private(set) var columns: [Column: Set<Row>]

    /// Tableau matrix.
    public private(set) var rows: [Row: RowInfo]

    /// Set of basic variables that have infeasible rows.
    /// This is used when re-optimizing with dual simplex method.
    public var infeasibleRows: Set<Row> = []

    /// Set of basic variables (`Row.variable` only).
    public private(set) var externalBasicRows: Set<Row> = []

    /// Set of non-basic variables (`Column.variable` only).
    public private(set) var externalParametricColumns: Set<Column> = []

    public init(columns: [Column: Set<Row>] = [:], rows: [Row: RowInfo] = [:])
    {
        self.columns = columns
        self.rows = rows
    }

    // MARK: Row

    public mutating func insertRow(_ row: Row, rowInfo: RowInfo)
    {
        self.rows[row] = rowInfo

        for (column, _) in rowInfo.terms {
            // Insert `row` for indexing.
            self.insertColumn(column, indexingRow: row)
            if column.isExternal {
                self.externalParametricColumns.insert(column)
            }
        }

        if row.isExternal {
            self.externalBasicRows.insert(row)
        }
    }

    @discardableResult
    public mutating func removeRow(_ row: Row) -> RowInfo?
    {
        let rowInfo = self.rows.removeValue(forKey: row)

        if let columns = rowInfo?.terms.keys {
            for column in columns {
                // Remove `row` from index.
                self.columns[column]?.remove(row)
            }
        }

        self.infeasibleRows.remove(row)

        if row.isExternal {
            self.externalBasicRows.remove(row)
        }

        return rowInfo
    }

    // MARK: Column

    /// Insert `row` to `self.columns[column]` which is `Set<Row>`.
    public mutating func insertColumn(_ column: Column, indexingRow row: Row)
    {
        self.columns[column, default: Set<Row>()].insert(row)
    }

    public mutating func removeColumn(_ column: Column)
    {
        let rows = self.columns.removeValue(forKey: column)
        if let rows = rows {
            for row in rows {
                self.rows[row]?.terms.removeValue(forKey: column)
            }
        }

        if column.isExternal {
            self.externalBasicRows.remove(Row(column: column))
            self.externalParametricColumns.remove(column)
        }
    }

    /// Add `coeff * column` to objective function.
    /// This is used for adding error variables.
    public mutating func addToObjective(column: Column, coeff: Double)
    {
        var objectiveRowInfo = self.rows[.objective, default: RowInfo()]
        objectiveRowInfo.terms[column, default: 0] += coeff

        if objectiveRowInfo.terms[column]!.isNearlyEqual(to: 0) {
            // Remove 0 from rowInfo.
            objectiveRowInfo.terms.removeValue(forKey: column)
            self.columns[column]?.remove(.objective)
        }
        else {
            self.insertColumn(column, indexingRow: .objective)
        }

        self.rows[.objective] = objectiveRowInfo
    }

    public mutating func updateRowConstant(row: Row, constant: Double)
    {
        guard self.rows[row] != nil else { return }
        self.rows[row]!.constant = constant
    }

    // MARK: Pivot

    /// Move `entryColumn` as basic variable and leave `exitColumn` as non-basic variable.
    public mutating func pivot(entryColumn: Column, exitColumn: Column)
    {
        Debug.printTableau(self, "before pivot \(exitColumn) -> \(entryColumn)")
        defer {
            Debug.printTableau(self, "after pivot \(exitColumn) -> \(entryColumn)")
        }

        let exitRow = Row(column: exitColumn)
        let entryRow = Row(column: entryColumn)

        var rowInfo = self.removeRow(exitRow)!
        rowInfo.terms[exitColumn] = rowInfo.solve(column: entryColumn)
        self._parametrizeRows(solvedColumn: entryColumn, solvedRowInfo: rowInfo)
        self.insertRow(entryRow, rowInfo: rowInfo)
    }

    /// Substitute all existing rows that have non-zero coeffs for `entryColumn`
    /// using new `rowInfo`.
    ///
    /// - Parameter solvedRowInfo:
    ///   `RowInfo` that should be in "basic feasible solved form" for `entryColumn`,
    ///    e.g. `solvedRowInfo = [x1: 1, x3: 3]` for `entryColumn = x1 + 3 * x3`.
    internal mutating func _parametrizeRows(solvedColumn: Column, solvedRowInfo: RowInfo)
    {
        if let rows = self.columns[solvedColumn] {
            for row in rows {
                self._parametrizeRow(row: row, solvedColumn: solvedColumn, solvedRowInfo: solvedRowInfo)
            }
        }

        if solvedColumn.isExternal {
            self.externalBasicRows.insert(Row(column: solvedColumn))
            self.externalParametricColumns.remove(solvedColumn)
        }

        self.columns.removeValue(forKey: solvedColumn)
    }

    /// Substitute tableau's single rowInfo (i.e. `self.rows[row]`) with `solvedRowInfo`.
    ///
    /// For example, if `self.rows[row] = [x1: 1, x2: 2]` and `solvedRowInfo = `[x1: 1, x3: 3]` for `column = x2`,
    /// it will modify as `self.rows[row] = [x1: 3, x3: 6]`
    /// since `solvedRowInfo` is represented as `x2 = x1 + 3 * x3` so that
    /// `self = x1 + 2 * x2 = x1 + 2 * (x1 + 3 * x3) = 3 * x1 + 6 * x3`.
    ///
    /// - Parameter solvedRowInfo:
    ///   `RowInfo` that should be in "basic feasible solved form" for `entryColumn`,
    ///    e.g. `solvedRowInfo = [x1: 1, x3: 3]` for `entryColumn = x1 + 3 * x3`.
    private mutating func _parametrizeRow(row: Row, solvedColumn: Column, solvedRowInfo: RowInfo)
    {
        guard var existingRowInfo = self.rows[row] else { return }

        let multiplier = existingRowInfo.terms.removeValue(forKey: solvedColumn) ?? 0
        existingRowInfo.constant += multiplier * solvedRowInfo.constant

        for (column, coeff) in solvedRowInfo.terms {
            let oldCoeff = existingRowInfo.terms[column]
            if let oldCoeff = oldCoeff {
                let newCoeff = oldCoeff + multiplier * coeff
                if newCoeff.isNearlyEqual(to: 0) {
                    // Remove 0 from rowInfo.
                    existingRowInfo.terms.removeValue(forKey: column)
                    self.columns[column]?.remove(row)
                }
                else {
                    existingRowInfo.terms[column] = newCoeff
                }
            }
            else {
                existingRowInfo.terms[column] = multiplier * coeff
                self.insertColumn(column, indexingRow: row)
            }
        }

        self.rows[row] = existingRowInfo

        if row.isRestricted && existingRowInfo.constant < 0 {
            self.infeasibleRows.insert(row)
        }
    }

    // MARK: RowInfo Parametrization

    /// Substitute new `rowInfo` using current tableau's *basic feasible solved form*
    /// to represent as non-basic variables only.
    ///
    /// For example, if `rowInfo = [x1: 1, x2: 2]` and current tableau has
    /// `rows = [x1: [...], x3: [...], ...]`, `rowInfo[x1]` will be removed
    /// and replaced as non-basic variables, e.g. `newRowInfo = [x2: ..., x3: ...]`
    public func parametrizeRowInfo(_ rowInfo: RowInfo) -> RowInfo
    {
        // Start with `rowInfo.constant`.
        var newRowInfo = RowInfo(constant: rowInfo.constant)

        // Add each column of `rowInfo` with substitution from current tableau if possible.
        for (column, coeff) in rowInfo.terms {
            if let basicRowInfo = self.rows[.init(column: column)] {
                // If `column` is basic variable, substitute out.
                newRowInfo += coeff * basicRowInfo
            }
            else {
                // If `column` is not basic variable, just add the original coeff.
                newRowInfo.terms[column, default: 0] += coeff
            }
        }

        // Remove zeros in newRowInfo.
        newRowInfo.terms = newRowInfo.terms.filter { !$1.isNearlyEqual(to: 0) }

        Debug.print("    before substitute rowInfo = \(rowInfo)")
        Debug.print("    after  substitute rowInfo = \(newRowInfo)")

        return newRowInfo
    }
}

// MARK: CustomStringConvertible

extension Tableau: CustomStringConvertible
{
    public var description: String
    {
        let rows = self.rows
            .sorted { $0.key < $1.key }
            .map { "\(_leftPad("\($0.key)", length: 10)): \($0.value)" }
            .joined(separator: "\n")

        return """
        [Tableau] Columns: \(Array(columns.keys.sorted(by: <)))
          Rows:
        \(rows)
        """
    }
}
