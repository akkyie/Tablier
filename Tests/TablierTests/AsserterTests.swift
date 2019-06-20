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

final class AsserterTests: XCTestCase {
    func testFail() {
        let failExpectation = expectation(description: "Asserter.fail")
        let test = MockTest(didCallFail: {
            failExpectation.fulfill()
        })

        Asserter(test).fail(description: "", file: #file, line: #line)

        wait(for: [failExpectation], timeout: 0.1)
    }

    func testExpectation() {
        let expectationExpectation = expectation(description: "Asserter.expectation")
        let test = MockTest(didCallExpectation: {
            expectationExpectation.fulfill()
        })

        _ = Asserter(test).expectation(description: "", file: #file, line: #line)

        wait(for: [expectationExpectation], timeout: 0.1)
    }

    func testWait() {
        let waitExpectation = expectation(description: "Asserter.wait")
        let test = MockTest(didCallWait: {
            waitExpectation.fulfill()
        })

        Asserter(test).wait(for: [MockExpectation(fulfillClosure: {})], timeout: 100,
                            enforceOrder: false, file: #file, line: #line)

        wait(for: [waitExpectation], timeout: 0.1)
    }

    func testDescription() {
        do {
            let description = Asserter(MockTest()).assertionDescription(
                for: TestDebugDescription(),
                expected: "expected",
                descriptions: ["a", "b", "c"]
            )

            XCTAssertEqual(description, "expected: \"expected\" - actual: debugDescription - a - b - c")
        }

        do {
            let description = Asserter(MockTest()).assertionDescription(
                for: TestDescription(),
                expected: "expected",
                descriptions: ["a", "b", "c"]
            )

            XCTAssertEqual(description, "expected: \"expected\" - actual: description - a - b - c")
        }

        do {
            let description = Asserter(MockTest()).assertionDescription(
                for: Any.self,
                expected: "expected",
                descriptions: ["a", "b", "c"]
            )

            XCTAssertEqual(description, "expected: \"expected\" - actual: Any - a - b - c")
        }

        do {
            let description = Asserter(MockTest()).errorDescription(
                for: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "localizedDescription"]),
                expected: "expected",
                descriptions: ["a", "b", "c"]
            )

            XCTAssertEqual(description, "expected: \"expected\" - error: \"localizedDescription\" - a - b - c")
        }
    }
}
