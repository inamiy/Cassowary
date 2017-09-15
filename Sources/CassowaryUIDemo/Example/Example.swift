import Foundation
import CoreGraphics
import Cassowary
import CassowaryUI

/// Incremental constraint changing example.
struct Example
{
    let name: String
    let setup: SetupStrategy

    /// Constraints of views.
    let addingConstraints: (CGSize) -> ([Pair2]) -> [Constraint]

    internal init(
        _ name: String,
        setup: SetupStrategy = .none,
        addingConstraints: @escaping (CGSize) -> ([Pair2]) -> [Constraint] = { _ in { _ in [] } }
        )
    {
        self.name = name
        self.setup = setup
        self.addingConstraints = addingConstraints
    }
}

extension Example
{
    /// - Note:
    /// `.removePrevious` will remove previously set constraints,
    /// but this doesn't mean layout will be _fully reverted_,
    /// since there may be multiple optimal basic feasible solutions.
    static let removePrevious = Example("Remove Previous", setup: .removePrevious)
}

extension Example
{
    enum SetupStrategy
    {
        /// Do nothing (keep using previous constraints).
        case none

        /// Remove previous constraints before adding constraints.
        case removePrevious

        /// Remove all stored constraints (reset all).
        case removeAll
    }
}
