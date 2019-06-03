@testable import Tablier
import XCTest

#if canImport(Result)
    import Result
#endif

private struct Foo: Equatable {}

struct MockExpectation: Fulfillable {
    let mockFulfill: () -> Void
    func fulfill(_: StaticString, line _: Int) { mockFulfill() }
}

struct MockTest: Testable {
    let mockMakeExpectation: (_ description: String) -> Expectation
    let mockWait: ([MockExpectation], TimeInterval) -> Void
    let mockAssertSuccess: (Any, Any, StaticString, UInt) -> Void
    let mockAssertFailure: (Any, Any, StaticString, UInt) -> Void

    func expectation(description: String, file: StaticString, line: UInt) -> MockExpectation {
        return mockMakeExpectation(description)
    }

    func wait(for expectations: [MockExpectation], timeout: TimeInterval, enforceOrder: Bool, file: StaticString, line: UInt) {
        mockWait(expectations, timeout)
    }

    func assert<Output: Equatable>(actual: Result<Output, AnyError>, expected: Output, file: StaticString, line: UInt) {
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
        let scenario = Scenario<String, Int> { _ in
            XCTFail("initializer should not run the actual scenario")
            return 0
        }

        XCTAssertEqual(scenario.timeout, 0,
                       "sync initializer should have 0s timeout")
    }

    func testAsync() {
        do {
            let scenario = Scenario<String, Int> { _, completion in
                XCTFail("initializer should not run the actual scenario")
                completion(.success(0))
            }

            XCTAssertEqual(scenario.timeout, 5,
                           "init(async:) should have default timeout")
        }

        do {
            let scenario = Scenario<String, Int>(timeout: 100) { _, completion in
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
        let scenario = Scenario<String, String>(description: "description") { _, completion in
            completion(.success("actual"))
        }
        scenario.when(input: "input").expect("expected")

        let makeExpectationExpectation = expectation(description: "makeExpectation")
        let fulfillExpectation = expectation(description: "fulfill")
        let waitExpectation = expectation(description: "wait")
        let assertExpectation = expectation(description: "assert")

        let mock = MockTest(mockMakeExpectation: { description in
            XCTAssertEqual(description, "description",
                           "mock should have the correct description")
            makeExpectationExpectation.fulfill()
            return MockExpectation(mockFulfill: {
                fulfillExpectation.fulfill()
            })
        }, mockWait: { expectations, _ in
            XCTAssertEqual(expectations.count, 1)
            waitExpectation.fulfill()
        }, mockAssertSuccess: { actual, expected, _, _ in
            XCTAssertEqual(actual as? String, "actual")
            XCTAssertEqual(expected as? String, "expected")
            assertExpectation.fulfill()
        }, mockAssertFailure: { _, _, _, _ in
            XCTFail()
            assertExpectation.fulfill()
        })

        scenario.assert(with: mock)

        wait(for: [
            makeExpectationExpectation,
            fulfillExpectation,
            waitExpectation,
            assertExpectation,
        ], timeout: 0, enforceOrder: false)
    }

    func testExpectFailure() {
        let scenario = Scenario<String, String>(description: "description") { _, completion in
            completion(.failure(.error(from: MockError())))
        }
        scenario.when(input: "input").expect("expected")

        let makeExpectationExpectation = expectation(description: "makeExpectation")
        let fulfillExpectation = expectation(description: "fulfill")
        let waitExpectation = expectation(description: "wait")
        let assertExpectation = expectation(description: "assert")

        let mock = MockTest(mockMakeExpectation: { description in
            XCTAssertEqual(description, "description",
                           "mock should have the correct description")
            makeExpectationExpectation.fulfill()
            return MockExpectation(mockFulfill: {
                fulfillExpectation.fulfill()
            })
        }, mockWait: { expectations, _ in
            XCTAssertEqual(expectations.count, 1)
            waitExpectation.fulfill()
        }, mockAssertSuccess: { _, _, _, _ in
            XCTFail()
            assertExpectation.fulfill()
        }, mockAssertFailure: { actual, expected, _, _ in
            XCTAssertEqual((actual as? AnyError)?.error as? MockError, MockError())
            XCTAssertEqual(expected as? String, "expected")
            assertExpectation.fulfill()
        })

        scenario.assert(with: mock)

        wait(for: [
            makeExpectationExpectation,
            fulfillExpectation,
            waitExpectation,
            assertExpectation,
        ], timeout: 0, enforceOrder: false)
    }

    func testNoCompeletionCall() {
        let scenario = Scenario<String, String>(description: "description") { _, completion in }
        scenario.when(input: "input").expect("expected")

        let fulfillExpectation = expectation(description: "fulfill")
        fulfillExpectation.isInverted = true

        let mock = MockTest(mockMakeExpectation: { description in
            return MockExpectation(mockFulfill: {
                fulfillExpectation.fulfill()
            })
        }, mockWait: { expectations, _ in
        }, mockAssertSuccess: { _, _, _, _ in
        }, mockAssertFailure: { _, _, _, _ in
        })

        scenario.assert(with: mock)

        wait(for: [fulfillExpectation], timeout: 0, enforceOrder: false)
    }

    func testIsCompleted() {
        let scenario = Scenario<Foo, Foo> { _ in
            return Foo()
        }

        let mock = MockTest(
            mockMakeExpectation: { _ in MockExpectation(mockFulfill: {}) },
            mockWait: { _, _ in },
            mockAssertSuccess: { _, _, _, _ in },
            mockAssertFailure: { _, _, _, _ in }
        )

        XCTAssertEqual(scenario.isCompleted, false,
                  "scenario.isCompleted should be false before assert()")

        scenario.when(input: Foo()).expect(Foo())

        XCTAssertEqual(scenario.isCompleted, false,
                       "scenario.isCompleted should be false after adding expectation")

        scenario.assert(with: mock)

        XCTAssertEqual(scenario.isCompleted, true,
                       "scenario.isCompleted should be true after assert()")

        scenario.when(input: Foo()).expect(Foo())

        XCTAssertEqual(scenario.isCompleted, false,
                       "scenario.isCompleted should be false after adding expectation")

        scenario.assert(with: mock)

        XCTAssertEqual(scenario.isCompleted, true,
                       "scenario.isCompleted should be true after assert()")

        scenario.assert(with: mock)
    }
}
