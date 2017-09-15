import XCTest
@testable import Simplex

class RemoveErrorTests: XCTestCase
{
    func testRemoveConstraints() throws
    {
        let constraint1: Constraint = x1 == x2
        let constraint1b: Constraint = x1 == x2
        let constraint2: Constraint = x3 >= x4

        let problem = Problem(
            minimize: 0,
            constraints: constraint1,
            allRestricted: true
        )

        let solver = try Solver(problem: problem)
        var solver2: Solver

        solver2 = solver
        XCTAssertThrowsError(try solver2.removeConstraints(constraint2)) { error in
            XCTAssertEqual(error as? Solver.Error, .removeError(.constraintNotFound(constraint2)))
        }

        solver2 = solver
        XCTAssertThrowsError(try solver2.removeConstraints(constraint1b)) { error in
            XCTAssertEqual(error as? Solver.Error, .removeError(.constraintNotFound(constraint1b)))
        }
    }
}
