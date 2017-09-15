import XCTest
@testable import Cassowary
import class Simplex.Variable

#if Xcode

class StayTests: XCTestCase
{
    func testStay() throws
    {
        var solver = Solver()

        let left = Variable("left")
        let width = Variable("width")
        let right = left + width

        try solver.beginEdit {
            try $0.addStayVariable(width, value: 10)
        }

        try XCTContext.runActivity(named: "equal") { _ in
            var solver = solver // copy
            try solver.addConstraints(right == 100)

            let solution = try solver.solve()
            print(solution)
            XCTAssertEqual(solution, [left: 90, width: 10])
        }

        try XCTContext.runActivity(named: "greaterThanOrEqual") { _ in
            var solver = solver // copy
            try solver.addConstraints(right >= 100)

            let solution = try solver.solve()
            print(solution)
            XCTAssertEqual(solution, [left: 90, width: 10])
        }

        try XCTContext.runActivity(named: "lessThanOrEqual") { _ in
            var solver = solver // copy
            try solver.addConstraints(right <= 100)

            let solution = try solver.solve()
            print(solution)
            XCTAssertEqual(solution, [left: 90, width: 10])
        }
    }

    func testMultipleStays() throws
    {
        var solver = Solver()

        let left1 = Variable("left")
        let width1 = Variable("width")
        let right1 = left1 + width1

        let left2 = Variable("left")
        let width2 = Variable("width")
        let right2 = left2 + width2

        try solver.beginEdit {
            try $0.addStayVariable(width1, value: 10)
            try $0.addStayVariable(width2, value: 10)
            try $0.addStayVariable(left2, value: 100)
        }

        try XCTContext.runActivity(named: "equal") { _ in
            var solver = solver // copy
            try solver.addConstraints(right1 == right2)

            let solution = try solver.solve()
            print(solution)
            XCTAssertEqual(solution, [left1: 100, width1: 10, left2: 100, width2: 10])
        }

        try XCTContext.runActivity(named: "greaterThanOrEqual") { _ in
            var solver = solver // copy
            try solver.addConstraints(right1 >= right2)

            let solution = try solver.solve()
            print(solution)
            XCTAssertEqual(solution, [left1: 100, width1: 10, left2: 100, width2: 10])
        }

        try XCTContext.runActivity(named: "lessThanOrEqual") { _ in
            var solver = solver // copy
            try solver.addConstraints(right1 <= right2)

            let solution = try solver.solve()
            print(solution)
            XCTAssertEqual(solution, [left1: 100, width1: 10, left2: 100, width2: 10])
        }
    }
}

#endif
