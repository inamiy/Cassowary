import XCTest
import Cassowary
@testable import CassowaryUI
import class Simplex.Variable

class BasicTests: XCTestCase
{
    func testCassowaryUI() throws
    {
        var solver = CassowaryUI.Solver()

        let rootSize = CGSize(width: 375, height: 667)
        let rootView = View(frame: CGRect(origin: .zero, size: rootSize))
        let v0 = View()
        let v1 = View()

        rootView.addSubview(v0)
        rootView.addSubview(v1)

        let constraints: ([Pair2]) -> [Constraint] = { rootSize in { vs in
            var constraints = [Constraint]()

            // Setup `vs[0]` (`.high` for editability).
            constraints.append(contentsOf: [
                vs[0].top == 40 ~ .medium,
                vs[0].left == 20 ~ .medium,
                vs[0].right == rootSize.width - 20 ~ .medium,
                vs[0].bottom == rootSize.height - 40 ~ .medium
            ])

            constraints.append(contentsOf: [
                vs[1].left >= vs[0].left + 20 ~ .required,
                vs[1].right <= vs[0].right - 20 ~ .required,
                vs[1].top >= vs[0].top + 20 ~ .required,
                vs[1].bottom <= vs[0].bottom - 20 ~ .required
            ])

            return constraints
        }}(rootSize)

        try solver.addConstraints([v0, v1], setup: constraints)
        solver.applyLayout()

        XCTAssertEqual(v0.frame, CGRect(x: 20, y: 40, width: 335, height: 587))
        XCTAssertEqual(v1.frame, CGRect(x: 40, y: 60, width: 295, height: 547))

        // MARK: 1st beginEdit

        try solver.beginEdit {
            try $0.addEditVariable(v0.cassowary.right, priority: .high)
        }

        try solver.suggest {
            try $0.suggestValue(100, for: v0.cassowary.right)
        }

        XCTAssertEqual(v0.frame, CGRect(x: 20, y: 40, width: 80, height: 587))
        XCTAssertEqual(v1.frame, CGRect(x: 40, y: 60, width: 40, height: 547))

        solver.applyLayout()

        XCTAssertEqual(v0.frame, CGRect(x: 20, y: 40, width: 80, height: 587))
        XCTAssertEqual(v1.frame, CGRect(x: 40, y: 60, width: 40, height: 547))

        try solver.endEdit()

        // MARK: 2nd beginEdit

        for _ in 0...0 {
            try solver.beginEdit {
                try $0.addEditVariable(v0.cassowary.right, priority: .high)
            }

            try solver.suggest {
                try $0.suggestValue(200, for: v0.cassowary.right)
            }

            try solver.solve()
            solver.applyLayout()

            XCTAssertEqual(v0.frame, CGRect(x: 20, y: 40, width: 180, height: 587))
            XCTAssertEqual(v1.frame, CGRect(x: 40, y: 60, width: 140, height: 547))
        }

    }
}
