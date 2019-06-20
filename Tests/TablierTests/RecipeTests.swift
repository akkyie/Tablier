@testable import Tablier
import XCTest

private struct StubError: Error, Equatable {}

final class RecipeTests: XCTestCase {
    func testInitClosure() {
        do {
            let recipe = Recipe<String, String> { _, completion in
                completion("result", nil)
            }

            recipe.recipe("input") { (actual, error) in
                XCTAssertEqual(actual, "result",
                               "recipe should have the clousure passed by its initializer")
                XCTAssertNil(error)
            }
        }

        do {
            let recipe = Recipe<String, String> { _, completion in
                completion(nil, StubError())
            }

            recipe.recipe("input") { (actual, error) in
                XCTAssertNil(actual)
                XCTAssertEqual(error as? StubError, StubError(),
                               "recipe should have the clousure passed by its initializer")
            }
        }

        do {
            let successRecipe = Recipe<String, String> { _ in
                return "result"
            }

            successRecipe.recipe("input") { (actual, error) in
                XCTAssertEqual(actual, "result",
                               "Sync initalizer should pass closure to async initializer")
                XCTAssertNil(error)
            }
        }

        do {
            let failureRecipe = Recipe<String, String> { _ in
                throw StubError()
            }

            failureRecipe.recipe("input") { (actual, error) in
                XCTAssertNil(actual)
                XCTAssertEqual(error as? StubError, StubError(),
                               "Sync initalizer should pass closure to async initializer")
            }
        }
    }

    func testInitTimeout() {
        do {
            let recipe = Recipe<String, String> { _ in
                XCTFail("initializer should not run the actual recipe")
                return "result"
            }

            XCTAssertEqual(recipe.timeout, 0,
                           "inint(sync:) should have 0 timeout")
        }

        do {
            let recipe = Recipe<String, String> { _, _ in
                XCTFail("initializer should not run the actual recipe")
            }

            XCTAssertEqual(recipe.timeout, 5,
                           "init(async:) should have default timeout")
        }

        do {
            let recipe = Recipe<String, String>(timeout: 100) { _, _ in
                XCTFail("initializer should not run the actual recipe")
            }

            XCTAssertEqual(recipe.timeout, 100,
                           "timeout should be configurable")
        }
    }

    func testAssertInit() {
        let mockTest = MockTest()

        let recipe = Recipe<String, String> { _, _ in
            XCTFail("initializer should not run when no test case is added")
        }

        recipe.assert(with: mockTest) { _ in }
    }

    func testPassingAssert() {
        let expectationExpectation = expectation(description: "`expectation` should be called")
        let failExpectation = expectation(description: "`fail` should NOT be called")
        failExpectation.isInverted = true
        let fulfillExpectation = expectation(description: "`fulfill` should be called")
        let waitExpectation = expectation(description: "`wait` should be called")

        let mockTest = MockTest(
            didCallFail: { failExpectation.fulfill() },
            didCallExpectation: { expectationExpectation.fulfill() },
            didCallWait: { waitExpectation.fulfill() },
            didCallFulfill: { fulfillExpectation.fulfill() }
        )

        let recipe = Recipe<String, String> { _, completion in
            completion("expected", nil)
        }

        recipe.assert(with: mockTest) {
            $0.when("input").expect("expected")
        }

        wait(for: [
            expectationExpectation,
            failExpectation,
            fulfillExpectation,
            waitExpectation,
        ], timeout: 0.1, enforceOrder: true)
    }

    func testFailingAssert() {
        let expectationExpectation = expectation(description: "`expectation` should be called")
        let failExpectation = expectation(description: "`fail` should be called")
        let fulfillExpectation = expectation(description: "`fulfill` should be called")
        let waitExpectation = expectation(description: "`wait` should be called")

        let mockTest = MockTest(
            didCallFail: { failExpectation.fulfill() },
            didCallExpectation: { expectationExpectation.fulfill() },
            didCallWait: { waitExpectation.fulfill() },
            didCallFulfill: { fulfillExpectation.fulfill() }
        )

        let recipe = Recipe<String, String> { _, completion in
            completion("FOOBAR", nil)
        }

        recipe.assert(with: mockTest) {
            $0.when("input").expect("expected")
        }

        wait(for: [
            expectationExpectation,
            failExpectation,
            fulfillExpectation,
            waitExpectation,
            ], timeout: 0.1, enforceOrder: true)
    }

    func testErrorAssert() {
        let expectationExpectation = expectation(description: "`expectation` should be called")
        let failExpectation = expectation(description: "`fail` should be called")
        let fulfillExpectation = expectation(description: "`fulfill` should be called")
        let waitExpectation = expectation(description: "`wait` should be called")

        let mockTest = MockTest(
            didCallFail: { failExpectation.fulfill() },
            didCallExpectation: { expectationExpectation.fulfill() },
            didCallWait: { waitExpectation.fulfill() },
            didCallFulfill: { fulfillExpectation.fulfill() }
        )

        let recipe = Recipe<String, String> { _, completion in
            completion(nil, StubError())
        }

        recipe.assert(with: mockTest) {
            $0.when("input").expect("expected")
        }

        wait(for: [
            expectationExpectation,
            failExpectation,
            fulfillExpectation,
            waitExpectation,
            ], timeout: 0.1, enforceOrder: true)
    }

    func testInvalidCompletion() {
        do { // both actual and error is given
            let expectationExpectation = expectation(description: "`expectation` should be called")
            let failExpectation = expectation(description: "`fail` should be called")
            let fulfillExpectation = expectation(description: "`fulfill` should be called")
            let waitExpectation = expectation(description: "`wait` should be called")

            let mockTest = MockTest(
                didCallFail: { failExpectation.fulfill() },
                didCallExpectation: { expectationExpectation.fulfill() },
                didCallWait: { waitExpectation.fulfill() },
                didCallFulfill: { fulfillExpectation.fulfill() }
            )

            let recipe = Recipe<String, String> { _, completion in
                completion("expected", StubError())
            }

            recipe.assert(with: mockTest) {
                $0.when("input").expect("expected")
            }

            wait(for: [
                expectationExpectation,
                failExpectation,
                fulfillExpectation,
                waitExpectation,
            ], timeout: 0.1, enforceOrder: true)
        }

        do { // both actual and error is not given
            let expectationExpectation = expectation(description: "`expectation` should be called")
            let failExpectation = expectation(description: "`fail` should be called")
            let fulfillExpectation = expectation(description: "`fulfill` should be called")
            let waitExpectation = expectation(description: "`wait` should be called")

            let mockTest = MockTest(
                didCallFail: { failExpectation.fulfill() },
                didCallExpectation: { expectationExpectation.fulfill() },
                didCallWait: { waitExpectation.fulfill() },
                didCallFulfill: { fulfillExpectation.fulfill() }
            )

            let recipe = Recipe<String, String> { _, completion in
                completion(nil, nil)
            }

            recipe.assert(with: mockTest) {
                $0.when("input").expect("expected")
            }

            wait(for: [
                expectationExpectation,
                failExpectation,
                fulfillExpectation,
                waitExpectation,
            ], timeout: 0.1, enforceOrder: true)
        }
    }
}
