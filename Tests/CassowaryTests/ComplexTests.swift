import XCTest
@testable import Cassowary
import class Simplex.Variable

class ComplexTests: XCTestCase
{
    // https://constraints.cs.washington.edu/solvers/uist97.pdf
    func testPaper97() throws
    {
        var solver = Solver()

        let xl = Variable("xl")
        let xm = Variable("xm")
        let xr = Variable("xr")

        try solver.addConstraints(
            2 * xm == xl + xr,
            xl + 10 <= xr,
            xr <= 100,
            0 <= xl
        )

        let solution = try solver.solve()
        XCTAssertEqual(solution, [xl: 90, xm: 95, xr: 100])

        try solver.addConstraints(
            xm == 50 ~ .medium,
            xl == 30 ~ .low,
            xr == 60 ~ .low
        )

        let solution2 = try solver.solve()
        print(solution2)
        XCTAssertEqual(solution2, [xl: 30, xm: 50, xr: 70])

        try solver.beginEdit {
            try $0.addStayVariable(xl, value: 30, priority: .low)
            try $0.addStayVariable(xr, value: 70, priority: .low)
            try $0.addEditVariable(xm, priority: .high)
        }
        try solver.suggest {
            try $0.suggestValue(60, for: xm)
        }
        let solution3 = try solver.solve()
        print(solution3)
        XCTAssertEqual(solution3, [xl: 30, xm: 60, xr: 90])

        let solution4 = try solver.suggest {
            try $0.suggestValue(90, for: xm)
        }
        try solver.endEdit()
        print(solution4)
        XCTAssertEqual(solution4, [xl: 80, xm: 90, xr: 100])
    }

    func testQuadrilateral() throws
    {
        var solver = Solver()

        typealias Point<T> = (x: T, y: T)

        let ps: [Point<Variable>] = [
            Point(x: Variable("p0x"), y: Variable("p0y")),
            Point(x: Variable("p1x"), y: Variable("p1y")),
            Point(x: Variable("p2x"), y: Variable("p2y")),
            Point(x: Variable("p3x"), y: Variable("p3y")),
        ]

        let pValues: [Point<Double>] = [(10, 10), (10, 200), (200, 200), (200, 10)]

        let ms: [Point<Variable>] = [
            Point(x: Variable("m0x"), y: Variable("m0y")),
            Point(x: Variable("m1x"), y: Variable("m1y")),
            Point(x: Variable("m2x"), y: Variable("m2y")),
            Point(x: Variable("m3x"), y: Variable("m3y")),
        ]

        var strength: Int = 250
        try solver.beginEdit {
            for (p, pValue) in zip(ps, pValues) {
                try $0.addStayVariable(p.x, value: pValue.x, priority: .optional(strength))
                try $0.addStayVariable(p.y, value: pValue.y, priority: .optional(strength))

                strength += 50
            }
        }

        for (i, j) in [(0, 1), (1, 2), (2, 3), (3, 0)] {
            try solver.addConstraints(
                ms[i].x == (ps[i].x + ps[j].x) / 2,
                ms[i].y == (ps[i].y + ps[j].y) / 2
            )
        }

        for i in [0, 1] {
            try solver.addConstraints(
                ps[i].x + 20 <= ps[2].x,
                ps[i].x + 20 <= ps[3].x
            )
        }

        for i in [0, 3] {
            try solver.addConstraints(
                ps[i].y + 20 <= ps[1].y,
                ps[i].y + 20 <= ps[2].y
            )
        }

        for p in ps {
            try solver.addConstraints(
                p.x >= 0,
                p.y >= 0,
                p.x <= 500,
                p.y <= 500
            )
        }

        let solution = try solver.solve()

        XCTAssertEqual(solution, [
            ps[0].x: 10, ps[0].y: 10,
            ps[1].x: 10, ps[1].y: 200,
            ps[2].x: 200, ps[2].y: 200,
            ps[3].x: 200, ps[3].y: 10,
            ms[0].x: 10, ms[0].y: 105,
            ms[1].x: 105, ms[1].y: 200,
            ms[2].x: 200, ms[2].y: 105,
            ms[3].x: 105, ms[3].y: 10,
        ])

        try solver.beginEdit {
            try $0.addEditVariable(ps[2].x)
            try $0.addEditVariable(ps[2].y)
        }
        let solution2 = try solver.suggest {
            try $0.suggestValue(300, for: ps[2].x)
            try $0.suggestValue(400, for: ps[2].y)
        }
        XCTAssertEqual(solution2, [
            ps[0].x: 10, ps[0].y: 10,
            ps[1].x: 10, ps[1].y: 200,
            ps[2].x: 300, ps[2].y: 400,
            ps[3].x: 200, ps[3].y: 10,
            ms[0].x: 10, ms[0].y: 105,
            ms[1].x: 155, ms[1].y: 300,
            ms[2].x: 250, ms[2].y: 205,
            ms[3].x: 105, ms[3].y: 10,
        ])

    }

}
