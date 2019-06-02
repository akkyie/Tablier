import XCTest
@testable import Tablier

final class MockAssertion: Assertable {
    struct Expectation: Fullfillable {
        func fulfill() {}
    }

    var description: String = ""
    var expectations: [Expectation] = []
    var assertions: [(actual: Any, expected: Any)] = []
    var waitCallCount: Int = 0

    func makeExpectation(description: String) -> Expectation {
        self.description = description

        let expectation = Expectation()
        expectations.append(expectation)
        return expectation
    }

    func wait(for expectations: [Expectation], timeout: TimeInterval) {
        waitCallCount += 1
    }

    func assert<Output: Equatable>(actual: Output, expected: Output, file: StaticString, line: UInt) {
        assertions.append((actual: actual, expected: expected))
    }
}

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
                completion(0)
            }

            XCTAssertEqual(scenario.timeout, 5,
                           "init(async:) should have default timeout")
        }

        do {
            let scenario = Scenario<String, Int>(timeout: 100) { input, completion in
                XCTFail("initializer should not run the actual scenario")
                completion(0)
            }

            XCTAssertEqual(scenario.timeout, 100,
                           "timeout should be configurable")
        }
    }

    func testCondition() {
        let scenario = Scenario<Void, Void> {
            XCTFail("making condition should not run the actual scenario")
            return
        }

        let condition = scenario.when(input: ())
        XCTAssert(condition.scenario === scenario)
        XCTAssert(condition.input == ())
    }

    func testExpectation() {
        let scenario = Scenario<Void, Void> {
            XCTFail("making expectation should not run the actual scenario")
            return
        }

        XCTAssert(scenario.testCases.isEmpty,
                  "scenario.expectations must be empty after initialization")

        scenario.when(input: ()).expect(())
        XCTAssertEqual(scenario.testCases.count, 1,
                       "expect() must append an expectation")

        scenario.when(input: ()).expect(())
        XCTAssertEqual(scenario.testCases.count, 2,
                       "expect() must append an expectation")
    }

    func testAssert() {
        let scenario = Scenario<String, String>(description: "description") { string in "actual" }

        scenario.when(input: "input").expect("expected")

        let mock = MockAssertion()
        scenario.assert(with: mock)

        XCTAssertEqual(mock.description, "description",
                       "mock should have the correct description")
        XCTAssertEqual(mock.expectations.count, 1,
                       "scenario.assert should add an expectation")
        XCTAssertEqual(mock.assertions.count, 1,
                       "scenario.assert should add an assertion")
        XCTAssertEqual(mock.assertions[0].actual as? String, "actual",
                       "assertion should have the correct actual value")
        XCTAssertEqual(mock.assertions[0].expected as? String, "expected",
                       "assertion should have the correct expected value")
        XCTAssertEqual(mock.waitCallCount, 1,
                       "scenario.assert should call assertion.wait")
    }
}
