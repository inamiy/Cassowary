import XCTest
@testable import Simplex

typealias Test<Err: Swift.Error> = (problem: Problem, expected: Expected<Err>)

protocol TestRunner
{
    associatedtype Err: Swift.Error, Equatable

    var tests: [Test<Err>] { get }
    func runTests()
}

extension TestRunner
{
    func runTests()
    {
        let iterations = 10
        let tests = (0..<iterations).flatMap { _ in self.tests }
        for test in tests {
            do {
                try XCTContext.runActivity(named: "\(test.problem)") { _ in
                    switch test.expected {
                    case let .solution(expectedSolution):
                        let solution = try test.problem.solve()

                        Debug.print("----------------------------------------")
                        Debug.print("problem = \(test.problem)")
                        Debug.print("solution = \(solution)")
                        Debug.print("objective: \(solution.objective) (actual) == \(expectedSolution.objective) (expected)")
                        Debug.print()

                        // Compare solution (objective and all variables)
                        XCTAssertEqual(solution, expectedSolution)

                    case let .partialSolution(expectedVariables):
                        let solution = try test.problem.solve()

                        Debug.print("----------------------------------------")
                        Debug.print("problem = \(test.problem)")
                        Debug.print("solution = \(solution)")
                        Debug.print("objective: \(solution.objective)")
                        Debug.print()

                        // Compare partial variables.
                        for (variable, expectedValue) in expectedVariables {
                            XCTAssertEqual(solution.variables[variable, default: .nan], expectedValue, accuracy: 1e-8, "Variable(\(variable)) has actual value = \(solution.variables[variable, default: .nan]), but expected value = \(expectedValue)")
                        }

                    case let .error(expectedError):
                        XCTAssertThrowsError(try test.problem.solve()) { error in
                            XCTAssertEqual(error as? Err, expectedError)
                        }
                    }
                }
            }
            catch {
                XCTFail("Simplex failed with error = \(error), for problem = \(test.problem)")
                return
            }
        }
    }
}
