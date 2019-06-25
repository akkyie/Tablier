@testable import Tablier
import XCTest

private struct TestDebugDescription: CustomDebugStringConvertible {
    var debugDescription: String {
        return "debugDescription"
    }
}

private struct TestDescription: CustomStringConvertible {
    var description: String {
        return "description"
    }
}

final class TesterTests: XCTestCase {
    func testFail() {
        let failExpectation = expectation(description: "Tester.fail")
        let testCase = MockTestCase()

        let tester = Tester(testCase, fail: { _, _, _ in failExpectation.fulfill() })
        tester.fail("", #file, #line)

        wait(for: [failExpectation], timeout: 0.1)
    }

    func testExpect() {
        let expectExpectation = expectation(description: "Tester.expect")
        let testCase = MockTestCase(didCallExpectation: { expectExpectation.fulfill() })

        let tester = Tester(testCase)
        let expect = tester.expect("", #file, #line)
        XCTAssertNotNil(expect)

        wait(for: [expectExpectation], timeout: 0.1)
    }

    func testWait() {
        let waitExpectation = expectation(description: "Tester.wait")
        let testCase = MockTestCase(didCallWait: { waitExpectation.fulfill() })

        let tester = Tester(testCase)
        let expect: MockExpectation! = tester.expect("", #file, #line)

        tester.wait([expect], 1, false, #file, #line)

        wait(for: [waitExpectation], timeout: 0.1)
    }

    func testDescription() {
        do {
            let description = Tester(MockTestCase()).assertionDescription(
                for: TestDebugDescription(),
                expected: "expected",
                descriptions: ["a", "b", "c"]
            )

            XCTAssertEqual(description, "expected: \"expected\" - actual: debugDescription - a - b - c")
        }

        do {
            let description = Tester(MockTestCase()).assertionDescription(
                for: TestDescription(),
                expected: "expected",
                descriptions: ["a", "b", "c"]
            )

            XCTAssertEqual(description, "expected: \"expected\" - actual: description - a - b - c")
        }

        do {
            let description = Tester(MockTestCase()).assertionDescription(
                for: Any.self,
                expected: "expected",
                descriptions: ["a", "b", "c"]
            )

            XCTAssertEqual(description, "expected: \"expected\" - actual: Any - a - b - c")
        }

        do {
            let description = Tester(MockTestCase()).errorDescription(
                for: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "localizedDescription"]),
                expected: "expected",
                descriptions: ["a", "b", "c"]
            )

            XCTAssertEqual(description, "expected: \"expected\" - error: \"localizedDescription\" - a - b - c")
        }
    }
}
