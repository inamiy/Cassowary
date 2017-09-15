import Foundation
import CoreGraphics
import Cassowary
import CassowaryUI

final class ExampleManager
{
    private let didChangeExample: (Example) -> ()

    internal var solver = CassowaryUI.Solver()

    private var constraintsStack: [[Constraint]] = []
    private var count: Int = 0

    private let examples: [Example] = [example1, example2, example3, example4]
//    private let examples: [Example] = [example0]

    init(_ didChangeExample: @escaping (Example) -> ())
    {
        self.didChangeExample = didChangeExample
    }

    func setupInitialLayout(rootSize: CGSize, views: [View])
    {
        self.count += 1
        self._setupLayout(rootSize: rootSize, views: views, example: self.examples[0])
    }

    private func _setupLayout(rootSize: CGSize, views: [View], example: Example)
    {
        print(#function, "count = \(self.count)")

        switch example.setup {
        case .removePrevious:
            if let constraints = self.constraintsStack.popLast() {
                try? self.solver.removeConstraints(constraints)
            }
        case .removeAll:
            // NOTE: Removing all histories can't run `.removePrevious` anymore.
            self.constraintsStack.removeAll()
            self.solver = CassowaryUI.Solver()
        case .none:
            break
        }

        let cs = try! self.solver.addConstraints(views, setup: example.addingConstraints(rootSize))
        self.constraintsStack.append(cs)

        self.didChangeExample(example)
    }

    func reloadCurrentLayout(rootSize: CGSize, views: [View])
    {
        self._setupLayout(rootSize: rootSize, views: views, example: self.examples[(self.count - 1) % self.examples.count])
    }

    func loadNextLayout(rootSize: CGSize, views: [View])
    {
        self.count += 1
        self._setupLayout(rootSize: rootSize, views: views, example: self.examples[(self.count - 1) % self.examples.count])
    }

    func applyLayout()
    {
        self.solver.applyLayout()
    }
}
