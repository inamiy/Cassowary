import XCTest
@testable import Simplex

#if Xcode

class DegeneracyTests: XCTestCase, TestRunner
{
    func test() { self.runTests() }

    let tests: [Test<Solver.Error>] = [

        // http://www.dais.is.tohoku.ac.jp/~shioura/teaching/mp11/mp11-03.pdf
        {
            let problem = Problem(
                minimize: -x1 - x2,
                constraints:
                x3 == 12.0 - 3 ** x1 - 2 ** x2,
                x4 == 4.0 - x1 - 2 ** x2,
                allRestricted: true
            )
            // Should not go into cycling (infinite loop)
            let solution = Solution(objective: -4, variables: [x1: 4.0, x2: 0.0, x3: 0.0, x4: 0.0])
            return (problem, .solution(solution))
        }(),

        // https://ocw.mit.edu/courses/sloan-school-of-management/15-053-optimization-methods-in-management-science-spring-2013/tutorials/MIT15_053S13_tut07.pdf
        {
            let problem = Problem(
                minimize: -0.75 ** x1 + 20 ** x2 - 0.5 ** x3 + 6 ** x4,
                constraints:
                0.25 ** x1 - 8 ** x2 - x3 + 9 ** x4 <= 0.0,
                0.5 ** x1 - 12 ** x2 - 0.5 ** x3 + 3 ** x4 <= 0.0,
                x3 <= 0.0,
                allRestricted: true
            )
            // Should not go into cycling (infinite loop)
            let solution = Solution(objective: 0, variables: [x1: 0.0, x2: 0.0, x3: 0.0, x4: 0.0])
            return (problem, .solution(solution))
        }()
    ]
}

#endif
