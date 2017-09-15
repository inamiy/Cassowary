import XCTest
@testable import Simplex

class IncrementalTests: XCTestCase
{
    func testIncrementalAdd_oneByOne() throws
    {
        // NOTE: Solve individually.
        let solution1a = try problem1.solve()
        let solution2a = try problem2.solve()
        let solution3a = try problem3.solve()

        // Incremental solving.
        var solver = try Solver(problem: problem1)
        let solution1b = try solver.solve()

        try solver.addConstraints(constraint2)
        let solution2b = try solver.solve()

        try solver.addConstraints(constraint3)
        let solution3b = try solver.solve()

        XCTAssertEqual(solution1a, solution1)
        XCTAssertEqual(solution2a, solution2)
        XCTAssertEqual(solution3a, solution3)

        XCTAssertEqual(solution1b, solution1)
        XCTAssertEqual(solution2b, solution2)
        XCTAssertEqual(solution3b, solution3)
    }

    func testIncrementalAdd_multiple() throws
    {
        let solution3 = try problem3.solve()
        let solver = try Solver(problem: problem1)

        // Test for remove-order independency.
        let constraintsArray = [[constraint2, constraint3], [constraint3, constraint2]]

        for constraints in constraintsArray {
            var solver2 = solver
            try solver2.addConstraints(constraints)

            let solution3b = try solver2.solve()
            XCTAssertEqual(solution3, solution3b, "Adding multiple constraints should succeed.")
        }
    }

    func testIncrementalRemove_oneByOne() throws
    {
        // NOTE: Solve individually.
        let solution1a = try problem1.solve()
        let solution2a = try problem2.solve()
        let solution3a = try problem3.solve()

        // Incremental solving.
        var solver = try Solver(problem: problem3)
        let solution3b = try solver.solve()

        try solver.removeConstraints(constraint3)
        let solution2b = try solver.solve()

        try solver.removeConstraints(constraint2)
        let solution1b = try solver.solve()

        XCTAssertEqual(solution1a, solution1)
        XCTAssertEqual(solution2a, solution2)
        XCTAssertEqual(solution3a, solution3)

        XCTAssertEqual(solution1b, solution1)
        XCTAssertEqual(solution2b, solution2)
        XCTAssertEqual(solution3b, solution3)
    }

    func testIncrementalRemove_multiple() throws
    {
        let solution1 = try problem1.solve()
        let solver = try Solver(problem: problem3)

        // Test for remove-order independency.
        let constraintsArray = [[constraint2, constraint3], [constraint3, constraint2]]

        for constraints in constraintsArray {
            var solver2 = solver
            try solver2.removeConstraints(constraints)

            let solution1b = try solver2.solve()
            XCTAssertEqual(solution1, solution1b, "Adding multiple constraints should succeed.")
        }
    }
}

// MARK: Fixtures

private let objective = 5 ** x1 + 3 ** x2
private let constraint1 = x1 + x2 <= 100
private let constraint2 = 4 ** x1 + 2 ** x2 <= 300.0
private let constraint3 = 4 ** x1 + 3 ** x2 <= 330.0

private let problem1 = Problem(
    maximize: objective,
    constraints: constraint1,
    allRestricted: true
)

private let problem2 = Problem(
    maximize: objective,
    constraints: constraint1, constraint2,
    allRestricted: true
)

private let problem3 = Problem(
    maximize: objective,
    constraints: constraint1, constraint2, constraint3,
    allRestricted: true
)

private let solution1 = Solution(objective: 500, variables: [x1: 100, x2: 0])
private let solution2 = Solution(objective: 400, variables: [x1: 50, x2: 50])
private let solution3 = Solution(objective: 390, variables: [x1: 60, x2: 30])
