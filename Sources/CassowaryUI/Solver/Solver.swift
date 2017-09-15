import CoreGraphics
import Cassowary
import struct Simplex.Solution
import class Simplex.Variable

/// Cassowary UI Solver.
public struct Solver
{
    private var cassowary: Cassowary.Solver
    private var views: Set<Weak<View>>

    /// Cached latest solution.
    public var cachedSolution: [Variable: Double]
    {
        return self.cassowary.cachedSolution
    }

    public init()
    {
        self.cassowary = Cassowary.Solver()
        self.views = []
    }

    public mutating func reset()
    {
        self = Solver()
    }

    // MARK: Add Constraints

    @discardableResult
    public mutating func addConstraints(
        _ view1: View,
        _ view2: View,
        setup: (Pair2, Pair2) -> [Constraint]
        ) throws -> [Constraint]
    {
        return try self.addConstraints([view1, view2]) { pairs in
            return setup(pairs[0], pairs[1])
        }
    }

    @discardableResult
    public mutating func addConstraints(
        _ view1: View,
        _ view2: View,
        _ view3: View,
        setup: (Pair2, Pair2, Pair2) -> [Constraint]
        ) throws -> [Constraint]
    {
        return try self.addConstraints([view1, view2, view3]) { pairs in
            return setup(pairs[0], pairs[1], pairs[2])
        }
    }

    @discardableResult
    public mutating func addConstraints(
        _ view1: View,
        _ view2: View,
        _ view3: View,
        _ view4: View,
        setup: (Pair2, Pair2, Pair2, Pair2) -> [Constraint]
        ) throws -> [Constraint]
    {
        return try self.addConstraints([view1, view2, view3, view4]) { pairs in
            return setup(pairs[0], pairs[1], pairs[2], pairs[3])
        }
    }

    @discardableResult
    public mutating func addConstraints(
        _ view1: View,
        _ view2: View,
        _ view3: View,
        _ view4: View,
        _ view5: View,
        setup: (Pair2, Pair2, Pair2, Pair2, Pair2) -> [Constraint]
        ) throws -> [Constraint]
    {
        return try self.addConstraints([view1, view2, view3, view4, view5]) { pairs in
            return setup(pairs[0], pairs[1], pairs[2], pairs[3], pairs[4])
        }
    }

    @discardableResult
    public mutating func addConstraints(
        _ views: [View],
        setup: ([Pair2]) -> [Constraint]
        ) throws -> [Constraint]
    {
        for view in views {
            self.views.insert(Weak(view))
        }

        let constraints = setup(views.map { $0._pair2 })
        let backup = self.cassowary

        do {
            try self.cassowary.addConstraints(constraints)
            try self.cassowary.solve()
        }
        catch let error {
            self.cassowary = backup
            throw error
        }

        return constraints
    }

    public mutating func solve() throws
    {
        try self.cassowary.solve()
    }

    // MARK: Remove Constraints

    /// - Throws: `Solver.RemoveError.notFound`
    public mutating func removeConstraints(_ constraints: Constraint...) throws
    {
        try self.removeConstraints(constraints)
    }

    /// - Throws: `Solver.RemoveError.notFound`
    public mutating func removeConstraints(_ constraints: [Constraint]) throws
    {
        try self.cassowary.removeConstraints(constraints)

        try self.cassowary.solve()
    }

    // MARK: Layout

    public func applyLayout()
    {
        /// Sort views for breadth-first layouting.
        let views = self.views
            .flatMap { $0.value }
            .sorted(by: { $0.depth < $1.depth })

        for view in views {
            let x = self.cachedSolution[view.cassowary.left]
                ?? Double(view.frame.origin.x)
            let y = self.cachedSolution[view.cassowary.top]
                ?? Double(view.frame.origin.y)
            let x2 = self.cachedSolution[view.cassowary.right]
                ?? Double(view.frame.size.width + view.frame.origin.x)
            let y2 = self.cachedSolution[view.cassowary.bottom]
                ?? Double(view.frame.size.height + view.frame.origin.y)

            let absoluteFrame = CGRect(x: x, y: y, width: x2 - x, height: y2 - y)
            let relativeFrame = view.superview!.convert(absoluteFrame, from: nil)

            view.frame = relativeFrame
        }
    }

    // MARK: Edit

    /// Register stay variables and edit variables via `register` closure to start `suggestValue`,
    /// e.g. `solver.beginEdit { $0.addEditVariable(x1) }`.
    ///
    /// - Note: `endEdit()` will remove registered stay variables and edit variables.
    /// - Note: Supports nested `beginEdit()`.
    ///
    /// - Parameter register: Closure with passed `BeginEditProxy` that can add stay variables and edit variables.
    ///
    /// - Throws:
    ///   - `Error.addError(.editVariableExists(variable))`
    ///   - `Error.addError(.stayVariableExists(variable))`
    ///   - `Error.optimizeError(.unbounded)`
    public mutating func beginEdit(_ register: (inout Cassowary.Solver.BeginEditProxy) throws -> ()) throws
    {
        try self.cassowary.beginEdit(register)
    }

    /// Unregister latest stay variables and edit variables from stack.
    ///
    /// - Throws:
    ///   - `Error.removeError(.constraintNotFound(constraint))`
    ///   - `Error.optimizeError(.dualOptimizeFailed)`
    public mutating func endEdit() throws
    {
        try self.cassowary.endEdit()
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
    public mutating func suggest(_ register: (inout Cassowary.Solver.SuggestProxy) throws -> ()) throws
    {
        try self.cassowary.suggest(register)
        self.applyLayout()
    }
}

extension View
{
    fileprivate var depth: Int
    {
        var depth = 0
        var view = self
        while let superview = view.superview {
            view = superview
            depth += 1
        }
        return depth
    }
}
