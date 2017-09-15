import Simplex

extension Solver
{
    /// `Solver`'s proxy used inside `solver.beginEdit { ... }`
    /// for safer `addStayVariable` and `addEditVariable` handling.
    public struct BeginEditProxy
    {
        internal private(set) var solver: Solver
        internal let existingStayVariables: Set<Variable>
        internal let existingEditVariables: Set<Variable>

        internal private(set) var accumulatingStayEditInfos = StayEditInfos()

        internal init(solver: Solver)
        {
            self.solver = solver

            let reducedStayEditInfos = solver.stayEditInfosStack.reduce(into: StayEditInfos()) { result, stackEditInfos in
                result += stackEditInfos
            }
            self.existingStayVariables = Set(reducedStayEditInfos.stayInfos.keys)
            self.existingEditVariables = Set(reducedStayEditInfos.editInfos.keys)
        }

        /// Add stay variable that stays at either designated `value`
        /// or current value evaluated from tableau.
        ///
        /// - Parameters:
        ///   - value: `variable`'s value to stay. If `nil`, current solution from tableau will be used.
        /// - Throws: `Error.addError(.stayVariableExists(variable))`
        public mutating func addStayVariable(_ variable: Variable, value: Double? = nil, priority: Priority = .low) throws
        {
            guard self.accumulatingStayEditInfos.stayInfos[variable] == nil else {
                throw Error.addError(.stayVariableExists(variable))
            }
            guard !self.existingStayVariables.contains(variable) else {
                throw Error.addError(.stayVariableExists(variable))
            }

            let currentValue: Double
            if let value = value {
                currentValue = value
            }
            else {
                let solution = self.solver.cachedSolution
                currentValue = solution[variable, default: 0]
            }

            Debug.print("===> addStayVariable: \(variable) == \(currentValue)")
            let stayConstraint = Constraint(raw: variable == currentValue, priority: priority)

            let markers = try self.solver._addConstraint(stayConstraint)
            let stayInfo = StayInfo(constraint: stayConstraint, markers: markers)
            self.accumulatingStayEditInfos.stayInfos[variable] = stayInfo
        }

        /// Add edit variable that can be incrementally updated via `suggestValue`.
        /// - Throws: `Error.addError(.editVariableExists(variable))`
        public mutating func addEditVariable(_ variable: Variable, priority: Priority = .high) throws
        {
            guard self.accumulatingStayEditInfos.editInfos[variable] == nil else {
                throw Error.addError(.editVariableExists(variable))
            }
            guard !self.existingEditVariables.contains(variable) else {
                throw Error.addError(.editVariableExists(variable))
            }

            let solution = self.solver.cachedSolution

            let value = solution[variable, default: 0]

            Debug.print("===> addEditVariable: \(variable) == \(value)")
            let editConstraint = Constraint(raw: -variable + value == 0, priority: priority)
            let markers = try self.solver._addConstraint(editConstraint)

            let editInfo = EditInfo(
                constraint: editConstraint,
                markers: markers,
                prevEditConstant: value
            )
            self.accumulatingStayEditInfos.editInfos[variable] = editInfo
        }
    }
}
