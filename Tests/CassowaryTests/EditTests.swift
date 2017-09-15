import XCTest
@testable import Cassowary
import class Simplex.Variable

class EditTests: XCTestCase
{
    // Cassowary original test
    func testEdit() throws
    {
        var solver = Solver()

        try solver.addConstraints(
            x3 == (x1 + x2) / 2,
            x2 == x1 + 10,
            x2 <= 100,
            x1 >= 0
        )

        let solution = try solver.solve()
        XCTAssertEqual(solution, [x1: 90, x2: 100, x3: 95])

        try solver.beginEdit {
            try $0.addEditVariable(x3)
        }
        let solution2 = try solver.suggest {
            try $0.suggestValue(90, for: x3)
        }
        try solver.endEdit()
        XCTAssertEqual(solution2, [x1: 85, x2: 95, x3: 90])
    }

    func testStayAndEdit() throws
    {
        var solver = Solver()

        try solver.beginEdit {
            try $0.addStayVariable(x1, priority: .low)
        }

        let solution = try solver.solve()
        XCTAssertEqual(solution, [x1: 0])

        try solver.beginEdit {
            try $0.addEditVariable(x1, priority: .required)
        }
        let solution2 = try solver.suggest {
            try $0.suggestValue(2, for: x1)
        }
        try solver.endEdit()
        XCTAssertEqual(solution2, [x1: 2])
    }

    func testMultipleEdits() throws
    {
        var solver = Solver()

        try solver.beginEdit {
            try $0.addStayVariable(x1, priority: .low)
        }
        try solver.addConstraints(x1 == x2)

        let solution = try solver.solve()
        XCTAssertEqual(solution, [x1: 0, x2: 0])

        try solver.beginEdit {
            try $0.addEditVariable(x1, priority: .required)
        }
        let solution2 = try solver.suggest {
            try $0.suggestValue(32, for: x1)
        }
        try solver.endEdit()
        XCTAssertEqual(solution2, [x1: 32, x2: 32])

        try solver.beginEdit {
            try $0.addEditVariable(x1, priority: .required)
        }
        let solution3 = try solver.suggest {
            try $0.suggestValue(10, for: x1)
        }
        try solver.endEdit()
        XCTAssertEqual(solution3, [x1: 10, x2: 10])
    }

    func testMultipleEdits_nested() throws
    {
        var solver = Solver()

        let x = Variable("x")
        let y = Variable("y")
        let w = Variable("w")
        let h = Variable("h")

        try solver.beginEdit {
            try $0.addStayVariable(x, value: 0)
            try $0.addStayVariable(y, value: 0)
            try $0.addStayVariable(w, value: 0)
            try $0.addStayVariable(h, value: 0)
            try $0.addEditVariable(x)
            try $0.addEditVariable(y)
        }

        let solution = try solver.suggest {
            try $0.suggestValue(10, for: x)
            try $0.suggestValue(20, for: y)
        }
        XCTAssertEqual(solution, [x: 10, y: 20, w: 0, h: 0])

        try solver.beginEdit {
            try $0.addEditVariable(w)
            try $0.addEditVariable(h)
        }
        let solution2 = try solver.suggest {
            try $0.suggestValue(30, for: w)
            try $0.suggestValue(40, for: h)
        }
        XCTAssertEqual(solution2, [x: 10, y: 20, w: 30, h: 40])

        let solution3 = try solver.suggest {
            try $0.suggestValue(50, for: x)
            try $0.suggestValue(60, for: y)
        }
        try solver.endEdit()
        try solver.endEdit()

        print(solution3)
        XCTAssertEqual(solution3, [x: 50, y: 60, w: 30, h: 40])
    }

}
