import XCTest
@testable import Cassowary
import class Simplex.Variable

class BasicTests: XCTestCase
{
    func testVariable_equal() throws
    {
        var solver = Solver()

        try solver.addConstraints(x1 == 100)

        let solution = try solver.solve()
        XCTAssertEqual(solution, [x1: 100])
    }

    func testVariable_greaterThanOrEqual() throws
    {
        var solver = Solver()

        try solver.addConstraints(x1 >= 100)

        let solution = try solver.solve()
        XCTAssertEqual(solution, [x1: 100])
    }

    func testVariable_lessThanOrEqual() throws
    {
        var solver = Solver()

        try solver.addConstraints(x1 <= 100)

        let solution = try solver.solve()
        XCTAssertEqual(solution, [x1: 100])
    }

    /// http://spa.jssst.or.jp/2002/spa02-6-2.pdf
    func testNonRequiredConstraints() throws
    {
        var solver = Solver()

        try solver.addConstraints(
            x1 + x2 == 5.0 ~ .high,
            x1 >= 2 ~ .high,
            x2 >= 1 ~ .high,
            x2 == 4 ~ .low
        )

        let solution = try solver.solve()
        XCTAssertEqual(solution, [x1: 2, x2: 3])
    }
}
