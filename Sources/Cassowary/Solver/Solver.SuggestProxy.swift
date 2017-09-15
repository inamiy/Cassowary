import Simplex

extension Solver
{
    /// `Solver`'s proxy used inside `solver.suggest { ... }` for safer handling.
    public struct SuggestProxy
    {
        internal private(set) var solver: Solver

        internal init(solver: Solver)
        {
            self.solver = solver
        }

        /// Suggest `value` for `editVariable`.
        ///
        /// - Important: `beginEdit()` with registering edit variable is required before calling this method.
        ///
        /// - Throws:
        ///   - `Error.editError(.editVariableNotFound(editVariable, suggestedValue: value))`
        ///   - `Error.optimizeError(.unbounded)`
        public mutating func suggestValue(_ value: Double, for editVariable: Variable) throws
        {
            let _editInfo: (EditInfo, Int)? = { stayEditInfosStack in
                for (i, stayEditInfos) in stayEditInfosStack.enumerated() {
                    if let editInfo = stayEditInfos.editInfos[editVariable] {
                        return (editInfo, i)
                    }
                }
                return nil
            }(self.solver.stayEditInfosStack)

            guard let (__editInfo, index) = _editInfo else {
                throw Error.editError(.editVariableNotFound(editVariable, suggestedValue: value))
            }
            var editInfo = __editInfo

            let delta = value - editInfo.prevEditConstant
            Debug.print("delta = \(value) - \(editInfo.prevEditConstant) = \(delta)")

            // Update `editInfo.prevEditConstant`.
            editInfo.prevEditConstant = value
            self.solver.stayEditInfosStack[index].editInfos[editVariable] = editInfo

            let editRows = zip(editInfo.markers.columns, [1.0, -1.0])
                .map { (Row(column: $0), $1)}

            Debug.print("editRows = \(editRows) for editVariable = \(editVariable)")

            // If either `errorPlusColumn` or `errorMinusColumn` is basic variable,
            // add or subtract `editCoeff * delta` to it's row's constant.
            // Note that editColumn's `editCoeff` is always `1` when entered into basic variable.
            for (editRow, sign) in editRows {
                if let rowInfo = self.solver.tableau.rows[editRow] {
                    let newConstant = rowInfo.constant + sign * delta
                    self.solver.tableau.updateRowConstant(row: editRow, constant: newConstant)

                    if newConstant < 0 {
                        self.solver.tableau.infeasibleRows.insert(editRow)
                    }
                    return
                }
            }

            // If neither `errorPlusColumn` nor `errorMinusColumn` is basic variable,
            // add `editCoeff * delta` to every row's constant where row has `errorPlusColumn`.
            if let rows = self.solver.tableau.columns[editInfo.markers.subMarker!] {
                for row in rows {
                    let rowInfo = self.solver.tableau.rows[row]!

                    let editCoeff = rowInfo.terms[editInfo.markers.subMarker!, default: 0]
                    let newConstant = rowInfo.constant + editCoeff * delta
                    self.solver.tableau.updateRowConstant(row: row, constant: newConstant)

                    Debug.printTableau(self.solver.tableau, "during suggestValue, row = \(row)")

                    if row.isRestricted && newConstant < 0 {
                        self.solver.tableau.infeasibleRows.insert(row)
                    }
                }
            }
        }

    }
}
