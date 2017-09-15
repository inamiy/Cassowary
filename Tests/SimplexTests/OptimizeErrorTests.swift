import XCTest
@testable import Simplex

#if Xcode

class OptimizeErrorTests: XCTestCase, TestRunner
{
    func test() { self.runTests() }

    let tests: [Test<Solver.Error>] = [
        {
            let problem = Problem(
                minimize: x1 + 0,
                constraints:
                x1 == 10,
                x1 == 5,
                allRestricted: true
            )
            return (problem, .error(.optimizeError(.infeasible)))
        }(),

        // http://www.dais.is.tohoku.ac.jp/~shioura/teaching/mp11/mp11-03.pdf
        {
            let problem = Problem(
                minimize: -2 ** x1 - x2 - x3,
                constraints:
                x4 == 4.0 + 2 ** x1 - 2 ** x2 + x3,
                x5 == 4.0 + 2 ** x1 - 4 ** x3,
                x6 == 1.0 + 4 ** x1 - 3 ** x2 + x3,
                allRestricted: true
            )
            return (problem, .error(.optimizeError(.unbounded)))
        }(),
    ]
}

#endif
