import XCTest
import Cassowary

class IncrementalTests: XCTestCase
{
    func testIncrementalAdd() throws
    {
        var solver = Solver()

        let c1 = x1 <= 20
        let c2 = x1 <= 10

        try solver.addConstraints(
            x1 == 100 ~ .low
        )

        let solution = try solver.solve()
        XCTAssertEqual(solution, [x1: 100])

        try solver.addConstraints(c1)

        let solution2 = try solver.solve()
        XCTAssertEqual(solution2, [x1: 20])

        try solver.addConstraints(c2)

        let solution3 = try solver.solve()
        XCTAssertEqual(solution3, [x1: 10])
    }

    func testIncrementalRemove() throws
    {
        var solver = Solver()

        let c1 = x1 <= 10
        let c2 = x1 <= 20

        try solver.addConstraints(
            x1 == 100 ~ .low,
            c1,
            c2
        )

        let solution = try solver.solve()
        XCTAssertEqual(solution, [x1: 10])

        try solver.removeConstraints(c1)

        let solution2 = try solver.solve()
        XCTAssertEqual(solution2, [x1: 20])

        try solver.removeConstraints(c2)

        let solution3 = try solver.solve()
        XCTAssertEqual(solution3, [x1: 100])
    }
}
