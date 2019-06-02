import XCTest
@testable import Tablier

fileprivate struct Foo: Equatable {}

struct MockExpectation: Fullfillable {
    let mockFullfill: () -> Void
    func fulfill() { mockFullfill() }
}

struct MockAssertion: Assertable {
    let mockMakeExpectation: (_ description: String) -> Expectation
    let mockWait: ([MockExpectation], TimeInterval) -> Void
    let mockAssertSuccess: (Any, Any, StaticString, UInt) -> Void
    let mockAssertFailure: (Any, Any, StaticString, UInt) -> Void

    func makeExpectation(description: String) -> MockExpectation {
        return mockMakeExpectation(description)
    }

    func wait(for expectations: [MockExpectation], timeout: TimeInterval) {
        mockWait(expectations, timeout)
    }

    func assert<Output: Equatable>(actual: Result<Output, Error>, expected: Output, file: StaticString, line: UInt) {
        switch actual {
        case let .success(actual):
            mockAssertSuccess(actual, expected, file, line)
        case let .failure(actual):
            mockAssertFailure(actual, expected, file, line)
        }
    }
}

struct MockError: Error, Equatable {}

final class ScenarioTests: XCTestCase {
    func testSync() {
        let scenario = Scenario<String, Int> { input in
            XCTFail("initializer should not run the actual scenario")
            return 0
        }

        XCTAssertEqual(scenario.timeout, 0)
    }

    func testAsync() {
        do {
            let scenario = Scenario<String, Int> { input, completion in
                XCTFail("initializer should not run the actual scenario")
                completion(.success(0))
            }

            XCTAssertEqual(scenario.timeout, 5,
                           "init(async:) should have default timeout")
        }

        do {
            let scenario = Scenario<String, Int>(timeout: 100) { input, completion in
                XCTFail("initializer should not run the actual scenario")
                completion(.success(0))
            }

            XCTAssertEqual(scenario.timeout, 100,
                           "timeout should be configurable")
        }
    }

    func testCondition() {
        let scenario = Scenario<Foo, Foo> { _ in
            XCTFail("making condition should not run the actual scenario")
            return Foo()
        }

        let condition = scenario.when(input: Foo())
        XCTAssert(condition.scenario === scenario)
        XCTAssert(condition.input == Foo())
    }

    func testExpectation() {
        let scenario = Scenario<Foo, Foo> { _ in
            XCTFail("making expectation should not run the actual scenario")
            return Foo()
        }

        XCTAssert(scenario.testCases.isEmpty,
                  "scenario.expectations must be empty after initialization")

        scenario.when(input: Foo()).expect(Foo())
        XCTAssertEqual(scenario.testCases.count, 1,
                       "expect() must append an expectation")

        scenario.when(input: Foo()).expect(Foo())
        XCTAssertEqual(scenario.testCases.count, 2,
                       "expect() must append an expectation")
    }

    func testExpectSuccess() {
        let scenario = Scenario<String, String>(description: "description") { string, completion in
            completion(.success("actual"))
        }
        scenario.when(input: "input").expect("expected")

        let makeExpectationExpectation = expectation(description: "makeExpectation")
        let fulfillExpectation = expectation(description: "fulfill")
        let waitExpectation = expectation(description: "wait")
        let assertExpectation = expectation(description: "assert")

        let mock = MockAssertion(mockMakeExpectation: { description in
            XCTAssertEqual(description, "description",
                           "mock should have the correct description")
            makeExpectationExpectation.fulfill()
            return MockExpectation(mockFullfill: {
                fulfillExpectation.fulfill()
            })
        }, mockWait: { expectations, timeout in
            XCTAssertEqual(expectations.count, 1)
            waitExpectation.fulfill()
        }, mockAssertSuccess: { actual, expected, _, _ in
            XCTAssertEqual(actual as? String, "actual")
            XCTAssertEqual(expected as? String, "expected")
            assertExpectation.fulfill()
        }, mockAssertFailure: { actual, expected, _, _ in
            XCTFail()
            assertExpectation.fulfill()
        })

        scenario.assert(with: mock)

        wait(for: [
            makeExpectationExpectation,
            fulfillExpectation,
            waitExpectation,
            assertExpectation
            ], timeout: 0)
    }

    func testExpectFailure() {
        let scenario = Scenario<String, String>(description: "description") { string, completion in
            completion(.failure(MockError()))
        }
        scenario.when(input: "input").expect("expected")

        let makeExpectationExpectation = expectation(description: "makeExpectation")
        let fulfillExpectation = expectation(description: "fulfill")
        let waitExpectation = expectation(description: "wait")
        let assertExpectation = expectation(description: "assert")

        let mock = MockAssertion(mockMakeExpectation: { description in
            XCTAssertEqual(description, "description",
                           "mock should have the correct description")
            makeExpectationExpectation.fulfill()
            return MockExpectation(mockFullfill: {
                fulfillExpectation.fulfill()
            })
        }, mockWait: { expectations, timeout in
            XCTAssertEqual(expectations.count, 1)
            waitExpectation.fulfill()
        }, mockAssertSuccess: { actual, expected, _, _ in
            XCTFail()
            assertExpectation.fulfill()
        }, mockAssertFailure: { actual, expected, _, _ in
            XCTAssertEqual(actual as? MockError, MockError())
            XCTAssertEqual(expected as? String, "expected")
            assertExpectation.fulfill()
        })

        scenario.assert(with: mock)

        wait(for: [
            makeExpectationExpectation,
            fulfillExpectation,
            waitExpectation,
            assertExpectation
            ], timeout: 0)
    }
}
