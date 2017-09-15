import XCTest
@testable import SimplexTests
@testable import CassowaryTests

XCTMain([
    testCase(SimplexTests.allTests),
    testCase(CassowaryTests.allTests),
])
