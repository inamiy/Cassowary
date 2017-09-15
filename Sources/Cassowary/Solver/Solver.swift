import Simplex

/// Cassowary solver using `Simplex.Solver`.
public struct Solver
{
    internal typealias Column = Tableau.Column
    internal typealias Row = Tableau.Row
    internal typealias RowInfo = Tableau.RowInfo

    /// Cached latest solution used for stay variables and edit variables.
    public private(set) var cachedSolution: [Variable: Double] = [:]

    internal var simplex: Simplex.Solver

    /// `beginEdit()` info stack.
    internal var stayEditInfosStack: [StayEditInfos] = []

    /// - Warning: This is a workaround for multiple `beginEdit()` not working correctly.
    private var _workaround_solverStack: [Solver] = []

    private var errorCounter: UInt = 0

    public init()
    {
        let problem = Problem(minimize: 0)
        self.simplex = try! Simplex.Solver(problem: problem) // swiftlint:disable:this force_try
    }

    internal var tableau: Tableau
    {
        get {
            return self.simplex.tableau
        }
        set {
            self.simplex.tableau = newValue
        }
    }

    // MARK: Solve

    /// `optimize` and `evaluateSolution`.
    /// - Throws: `Error.optimizeError(.unbounded)`
    @discardableResult
    public mutating func solve() throws -> [Variable: Double]
    {
        try self._optimize()
        let solution = self.simplex.evaluateSolution().variables
        self.cachedSolution = solution
        return solution
    }

    /// Keep pivoting until tableau is optimized.
    /// - Throws: `Error.optimizeError(.unbounded)`
    private mutating func _optimize() throws
    {
        do {
            try self.simplex.optimize()
        }
        catch Simplex.Solver.Error.optimizeError(.unbounded) {
            throw Error.optimizeError(.unbounded)
        }
    }

    /// - Throws: `Error.optimizeError(.dualOptimizeFailed)`
    private mutating func _solveDual() throws -> [Variable: Double]
    {
        try self._dualOptimize()
        let solution = self.simplex.evaluateSolution().variables
        self.cachedSolution = solution

        self.tableau.infeasibleRows.removeAll()
        self.resetStayConstants()

        return solution
    }

    /// - Throws: `Error.optimizeError(.dualOptimizeFailed)`
    private mutating func _dualOptimize() throws
    {
        do {
            try self.simplex.dualOptimize()
        }
        catch Simplex.Solver.Error.optimizeError(.dualOptimizeFailed) {
            throw Error.optimizeError(.dualOptimizeFailed)
        }
    }

    // MARK: Add Constraints

    /// - Throws:
    ///   - `Error.optimizeError(.infeasible)`
    ///   - `Error.optimizeError(.unbounded)`
    @discardableResult
    public mutating func addConstraints(_ constraints: Constraint...) throws -> [Constraint]
    {
        return try self.addConstraints(constraints)
    }

    /// - Throws:
    ///   - `Error.optimizeError(.infeasible)`
    ///   - `Error.optimizeError(.unbounded)`
    @discardableResult
    public mutating func addConstraints(_ constraints: [Constraint]) throws -> [Constraint]
    {
        for constraint in constraints {
            try self._addConstraint(constraint)
        }
        return constraints
    }

    /// - Throws:
    ///   - `Error.optimizeError(.infeasible)`
    ///   - `Error.optimizeError(.unbounded)`
    @discardableResult
    internal mutating func _addConstraint(_ constraint: Constraint) throws -> Markers
    {
        Debug.print()
        Debug.print("========================================")
        Debug.printTableau(self.tableau, "addConstraint: \(constraint)")
        defer {
            Debug.printTableau(self.tableau, "end addConstraint: \(constraint)")
            Debug.print("\n\n\n")
        }

        let (rowInfo, marker) = self._createRowInfo(constraint: constraint)

        let candidates = marker.columns
        do {
            try self.simplex.addRowInfo(rowInfo, candidates: candidates)
        }
        catch Simplex.Solver.Error.optimizeError(.infeasible) {
            throw Error.optimizeError(.infeasible)
        }
        catch Simplex.Solver.Error.optimizeError(.unbounded) {
            throw Error.optimizeError(.unbounded)
        }

        // NOTE: Optimizing per `addConstraint` is allowed in Cassowary algorithm.
        try self._optimize()

        return marker
    }

    /// Create `rowInfo` from `constraint` with its variables replaced by basic variables
    /// in the `tableau` (so that `rowInfo` will contain non-basic variables only).
    /// After that, slack & dummy variables are added to `rowInfo`.
    private mutating func _createRowInfo(constraint: Constraint) -> (RowInfo, Markers)
    {
        let rawConstraint = constraint.raw

        Debug.print("before createRowInfo")
        Debug.print("    constraint = \(rawConstraint)")
        Debug.print("    rowInfo = \(rawConstraint.rowInfo)")

        let mainMarker: Column
        var subMarker: Column?

        // Update `rowInfo` using current `tableau`.
        var newRowInfo = self.tableau.parametrizeRowInfo(rawConstraint.rowInfo)

        if rawConstraint.comparisonOperator == .equal {
            if constraint.priority == .required {
                // Add a dummy variable for marker.
                let dummy = Column.dummyVariable(self.simplex.makeDummyVariable())
                mainMarker = dummy
                subMarker = dummy

                newRowInfo.terms[dummy] = 1
            }
            else {
                // Add 2 error variables.
                self.errorCounter += 1
                let errPlus = Column.slackVariable(self._makeErrorVariable(suffix: "p\(self.errorCounter)"))
                mainMarker = errPlus
                let errMinus = Column.slackVariable(self._makeErrorVariable(suffix: "m\(self.errorCounter)"))
                subMarker = errMinus

                newRowInfo.terms[errPlus] = -1
                newRowInfo.terms[errMinus] = 1

                let weight = constraint.priority.weight!
                self.tableau.addToObjective(column: errMinus, coeff: weight)
                self.tableau.addToObjective(column: errPlus, coeff: weight)
            }
        }
        // Inequality
        else {
            // Add a slack variable.
            let slack = Column.slackVariable(self.simplex.makeSlackVariable())
            mainMarker = slack
            newRowInfo.terms[slack] = -1

            // Add an error variable if non-required priority.
            if case .optional = constraint.priority {
                let weight = constraint.priority.weight!

                self.errorCounter += 1
                let errMinus = Column.slackVariable(self._makeErrorVariable(suffix: "\(self.errorCounter)"))
                subMarker = errMinus
                newRowInfo.terms[errMinus] = 1

                self.tableau.addToObjective(column: errMinus, coeff: weight)
            }
        }

        self.simplex.markerVariables[rawConstraint] = mainMarker

        // Make constant positive.
        if newRowInfo.constant < 0 {
            newRowInfo *= -1
        }

        Debug.print("    final slack-added newRowInfo = \(newRowInfo)")
        Debug.print()

        let markers = Markers(main: mainMarker, sub: subMarker)

        return (newRowInfo, markers)
    }

    private mutating func _makeErrorVariable(suffix: String) -> SlackVariable
    {
        return SlackVariable(label: "e\(suffix)")
    }

    // MARK: Remove Constraints

    /// - Throws: `Error.removeError(.constraintNotFound(constraint))`
    public mutating func removeConstraints(_ constraints: Constraint...) throws
    {
        try self.removeConstraints(constraints)
    }

    /// - Throws: `Error.removeError(.constraintNotFound(constraint))`
    public mutating func removeConstraints(_ constraints: [Constraint]) throws
    {
        for constraint in constraints {
            try self._removeConstraint(constraint)
        }
    }

    /// - Throws: `Error.removeError(.constraintNotFound(constraint))`
    private mutating func _removeConstraint(_ constraint: Constraint) throws
    {
        let rawConstraint = constraint.raw

        do {
            self.resetStayConstants()
            return try self.simplex.removeConstraint(rawConstraint)
        }
        catch Simplex.Solver.Error.removeError(.constraintNotFound(rawConstraint)) {
            throw Error.removeError(.constraintNotFound(constraint))
        }
    }

    // MARK: Stay

    // Zero-ize all constants in stay-constraints where its errorPlus variable appears.
    public mutating func resetStayConstants()
    {
        let stayInfosArray = self.stayEditInfosStack.flatMap { $0.stayInfos.values }
        for stayInfos in stayInfosArray {
            let errorPlusColumn = stayInfos.markers.mainMarker
            let errorPlusRow = Row(column: errorPlusColumn)

            // If errorPlus is basic variable, reset errorPlus's constant to 0.
            self.simplex.tableau.updateRowConstant(row: errorPlusRow, constant: 0)
        }
    }

    // MARK: Edit

    /// Register stay variables and edit variables via `register` closure to start `suggestValue`,
    /// e.g. `solver.beginEdit { $0.addEditVariable(x1) }`.
    ///
    /// - Note: `endEdit()` will remove registered stay variables and edit variables.
    /// - Note: Supports nested `beginEdit()`.
    ///
    /// - Parameters:
    ///   - register: Closure with passed `BeginEditProxy` that can add stay variables and edit variables.
    ///
    /// - Throws:
    ///   - `Error.addError(.editVariableExists(variable))`
    ///   - `Error.addError(.stayVariableExists(variable))`
    ///   - `Error.optimizeError(.unbounded)`
    public mutating func beginEdit(_ register: (inout BeginEditProxy) throws -> ()) throws
    {
        Debug.printTableau(self.tableau, "before beginEdit")
        defer {
            Debug.printTableau(self.tableau, "after beginEdit")
        }

        self._workaround_solverStack.append(self)

        var proxy = BeginEditProxy(solver: self)
        try register(&proxy)
        self = proxy.solver

        self.stayEditInfosStack.append(proxy.accumulatingStayEditInfos)

        self.tableau.infeasibleRows.removeAll()
        self.resetStayConstants()

        try self._optimize()
    }

    /// Unregister latest stay variables and edit variables from stack.
    ///
    /// - Throws:
    ///   - `Error.removeError(.constraintNotFound(constraint))`
    ///   - `Error.optimizeError(.dualOptimizeFailed)`
    public mutating func endEdit() throws
    {
        Debug.printTableau(self.tableau, "before endEdit")
        defer {
            Debug.printTableau(self.tableau, "after endEdit")
        }

        if let solver = self._workaround_solverStack.last {
            self = solver
        }

        // FIXME & Comment-Out:
        // This incremental code should work,
        // but currently has a slight bug in core algorithm...
        // So `_workaround_solverStack` is used as a workaround.
//        do {
//            // Remove topmost stay variables and edit variables from stack.
//            if let lastStayEditInfos = self.stayEditInfosStack.popLast() {
//                for info in lastStayEditInfos.allInfos {
//                    let stayConstraint = info.constraint
//                    try self.removeConstraints(stayConstraint)
//
//                    if let subMarker = info.markers.subMarker {
//                        self.tableau.removeColumn(subMarker)
//                    }
//                }
//            }
//        }
//        catch Simplex.Solver.Error.optimizeError(.dualOptimizeFailed) {
//            throw Error.optimizeError(.dualOptimizeFailed)
//        }
    }

    /// Register suggesting values for `editVariable`s via `register` closure,
    /// e.g. `solver.suggest { $0.suggestValue(123, for: x1) }`.
    ///
    /// - Important:
    ///   `beginEdit()` with registering edit variable is required before calling this method.
    ///
    /// - Throws:
    ///   - `Error.editError(.editVariableNotFound(editVariable, suggestedValue: value))`
    ///   - `Error.optimizeError(.unbounded)`
    ///   - `Error.optimizeError(.dualOptimizeFailed)`
    @discardableResult
    public mutating func suggest(_ register: (inout SuggestProxy) throws -> ()) throws -> [Variable: Double]
    {
        Debug.printTableau(self.tableau, "before suggest")

        var proxy = SuggestProxy(solver: self)
        try register(&proxy)
        self = proxy.solver

        Debug.printTableau(self.tableau, "during suggest")

        let solution = try self._solveDual()

        Debug.printTableau(self.tableau, "after suggest")

        return solution
    }
}
