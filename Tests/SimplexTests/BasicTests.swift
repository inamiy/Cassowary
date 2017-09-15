import XCTest
@testable import Simplex

#if Xcode

class BasicTests: XCTestCase, TestRunner
{
    func test() { self.runTests() }

    let tests: [Test<Solver.Error>] = [
        {
            let problem = Problem(
                minimize: x1 + x2,
                constraints:
                x1 == 1,
                x2 == 2,
                allRestricted: true
            )
            let solution = Solution(objective: 3, variables: [x1: 1, x2: 2])
            return (problem, .solution(solution))
        }(),

        // http://sma.epfl.ch/~niemeier/opt09/opt09_ch06.pdf
        {
            let problem = Problem(
                minimize: x1 ++ x2 ++ x3,
                constraints:
                x1 + 2 ** x2 + 3 ** x3 == 3.0,
                -x1 + 2 ** x2 + 6 ** x3 == 2.0,
                -4 ** x2 - 9 ** x3 == -5.0,
                3 ** x3 + x4 == 1.0,
                allRestricted: true
            )
            let solution = Solution(objective: 1.75, variables: [x1: 0.5, x2: 5.0/4, x3: 0, x4: 1.0])
            return (problem, .solution(solution))
        }(),

        {
            let problem = Problem(
                maximize: 5 ** x1 + 3 ** x2,
                constraints:
                x1 + x2 <= 100,
                allRestricted: true
            )
            let solution = Solution(objective: 500, variables: [x1: 100, x2: 0])
            return (problem, .solution(solution))
        }(),

        {
            let problem = Problem(
                maximize: 5 ** x1 + 3 ** x2,
                constraints:
                x1 + x2 <= 100,
                4 ** x1 + 2 ** x2 <= 300.0,
                allRestricted: true
            )
            let solution = Solution(objective: 400, variables: [x1: 50, x2: 50])
            return (problem, .solution(solution))
        }(),

        {
            let problem = Problem(
                maximize: 5 ** x1 + 3 ** x2,
                constraints:
                x1 + x2 <= 100,
                4 ** x1 + 2 ** x2 <= 300.0,
                4 ** x1 + 3 ** x2 <= 330.0,
                allRestricted: true
            )
            let solution = Solution(objective: 390, variables: [x1: 60, x2: 30])
            return (problem, .solution(solution))
        }(),

        {
            let problem = Problem(
                maximize: 0.5 ** x1 + 3 ** x2 + x3 + 4 ** x4,
                constraints:
                x1 + x2 + x3 + x4 <= 40,
                2 ** x1 + x2 - x3 - x4 <= 10.0,
                -x2 + x4 <= 10,
                allRestricted: true
            )
            let solution = Solution(objective: 145, variables: [x1: 0, x2: 15, x3: 0, x4: 25])
            return (problem, .solution(solution))
        }(),

        // http://optlab.mcmaster.ca/feng/4O03/Two.Phase.Simplex.pdf
        {
            let problem = Problem(
                maximize: 2 ** x1 + 3 ** x2 + x3,
                constraints:
                x1 + x2 + x3 <= 40,
                2 ** x1 + x2 - x3 >= 10.0,
                -x2 + x3 >= 10,
                allRestricted: true
            )
            let solution = Solution(objective: 70, variables: [x1: 10, x2: 10, x3: 20])
            return (problem, .solution(solution))
        }(),

        // http://www.fujilab.dnj.ynu.ac.jp/lecture/system4.pdf
        {
            let problem = Problem(
                minimize: 4 ** x1 + x2,
                constraints:
                x1 + 3 ** x2 >= 4.0,
                2 ** x1 + x2 >= 3.0,
                allRestricted: true
            )
            let solution = Solution(objective: 3, variables: [x1: 0, x2: 3])
            return (problem, .solution(solution))
        }(),

        // http://www.bunkyo.ac.jp/~nemoto/lecture/mathpro/2002/2stage-simplex.pdf
        {
            let problem = Problem(
                maximize: -6 ** x1 + 6 ** x2,
                constraints:
                2 ** x1 + 3 ** x2 <= 6.0,
                -5 ** x1 + 9 ** x2 == 15.0,
                -6 ** x1 + 3 ** x2 >= 3.0,
                allRestricted: true
            )
            let solution = Solution(objective: 10, variables: [x1: 0, x2: 5.0/3])
            return (problem, .solution(solution))
        }(),

        {
            let problem = Problem(
                maximize: x1 + 3 ** x2 + 5 ** x3,
                constraints:
                -x1 + x2 + x3 <= 2,
                2 ** x1 + x2 - x3 == 8.0,
                x1 + 2 ** x2 - x3 >= 1.0,
                allRestricted: true
            )
            let solution = Solution(objective: 56, variables: [x1: 8, x2: 1, x3: 9])
            return (problem, .solution(solution))
        }(),

        {
            let problem = Problem(
                minimize: 12 ** x1 + 6 ** x2 + 10 ** x3,
                constraints:
                x1 + x2 + 2 ** x3 >= 10.0,
                3 ** x1 + x2 + x3 >= 20.0,
                allRestricted: true
            )
            let solution = Solution(objective: 90, variables: [x1: 5, x2: 5, x3: 0])
            return (problem, .solution(solution))
        }(),

        // http://dcs.gla.ac.uk/~fischerf/teaching/opt/notes/notes8.pdf
        {
            let problem = Problem(
                minimize: 6 ** x1 + 3 ** x2,
                constraints:
                x1 + x2 >= 1,
                2 ** x1 - x2 >= 1.0,
                3 ** x2 <= 2.0,
                allRestricted: true
            )
            let solution = Solution(objective: 5, variables: [x1: 2.0/3, x2: 1.0/3])
            return (problem, .solution(solution))
        }(),
    ]
}

#endif
