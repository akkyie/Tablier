@testable import Tablier
import XCTest

#if canImport(Result)
import Result
#endif

private struct Foo: Equatable {}
private struct StubError: Error, Equatable {}

final class RecipeTests: XCTestCase {
    func testInitSync() {
        do {
            let recipe = Recipe<Foo, Foo> { _ in
                XCTFail("initializer should not run the actual recipe")
                return Foo()
            }

            XCTAssertEqual(recipe.timeout, 0,
                           "inint(sync:) should have 0 timeout")
        }

        do {
            let successRecipe = Recipe<Void, Foo> { _ in
                return Foo()
            }

            successRecipe.recipe(()) { result in
                XCTAssertEqual(result.value, Foo(),
                               "Sync initalizer should pass closure to async initializer")
            }
        }

        do {
            let failureRecipe = Recipe<Foo, Foo> { _ in
                throw StubError()
            }

            failureRecipe.recipe(Foo()) { result in
                XCTAssertEqual(result.error?.error as? StubError, StubError(),
                               "Sync initalizer should pass closure to async initializer")
            }
        }
    }

    func testInitAsync() {
        do {
            let recipe = Recipe<Foo, Foo> { _, _ in
                XCTFail("initializer should not run the actual recipe")
            }

            XCTAssertEqual(recipe.timeout, 5,
                           "init(async:) should have default timeout")
        }

        do {
            let recipe = Recipe<Foo, Foo>(timeout: 100) { _, completion in
                XCTFail("initializer should not run the actual recipe")
                completion(.success(Foo()))
            }

            XCTAssertEqual(recipe.timeout, 100,
                           "timeout should be configurable")
        }
    }

    func testAssertInit() {
        let mockTest = MockTest()

        let recipe = Recipe<Foo, Foo> { _, _ in
            XCTFail("initializer should not run when no test case is added")
        }

        recipe.assert(with: mockTest) { _ in }
    }

    func testAssertSucceed() {
        let expectationExpectation = expectation(description: "expectation")
        let recipeExpectatation = expectation(description: "recipe")
        let assertExpectation = expectation(description: "assert")
        let failExpectation = expectation(description: "fail")
        failExpectation.isInverted = true
        let fulfillExpectation = expectation(description: "fulfill")
        let waitExpectation = expectation(description: "wait")

        let mockTest = MockTest(
            assertExpectation: assertExpectation,
            failExpectation: failExpectation,
            expectationExpectation: expectationExpectation,
            fulfillExpectation: fulfillExpectation,
            waitExpectation: waitExpectation
        )

        let recipe = Recipe<String, String> { input, completion in
            XCTAssertEqual(input, "input",
                           "assert(with:) should run the recipe")
            recipeExpectatation.fulfill()
            completion(.success("actual"))
        }

        recipe.assert(with: mockTest) { when in
            when("input").expect("expected")
        }

        wait(for: [
            expectationExpectation,
            recipeExpectatation,
            assertExpectation,
            failExpectation,
            fulfillExpectation,
            waitExpectation,
            ], timeout: 0.1, enforceOrder: true)
    }

    func testAssertFail() {
        let expectationExpectation = expectation(description: "expectation")
        let recipeExpectatation = expectation(description: "recipe")
        let assertExpectation = expectation(description: "assert")
        assertExpectation.isInverted = true
        let failExpectation = expectation(description: "fail")
        let fulfillExpectation = expectation(description: "fulfill")
        let waitExpectation = expectation(description: "wait")

        let mockTest = MockTest(
            assertExpectation: assertExpectation,
            failExpectation: failExpectation,
            expectationExpectation: expectationExpectation,
            fulfillExpectation: fulfillExpectation,
            waitExpectation: waitExpectation
        )

        let recipe = Recipe<String, String> { input, completion in
            XCTAssertEqual(input, "input",
                           "assert(with:) should run the recipe")
            recipeExpectatation.fulfill()
            completion(.failure(AnyError(StubError())))
        }

        recipe.assert(with: mockTest) { when in
            when("input").expect("expected")
        }

        wait(for: [
            expectationExpectation,
            recipeExpectatation,
            assertExpectation,
            failExpectation,
            fulfillExpectation,
            waitExpectation,
            ], timeout: 0.1, enforceOrder: true)
    }

    func testAssertNotComplete() {
        let expectationExpectation = expectation(description: "expectation")
        let recipeExpectatation = expectation(description: "recipe")
        let assertExpectation = expectation(description: "assert")
        assertExpectation.isInverted = true
        let failExpectation = expectation(description: "fail")
        failExpectation.isInverted = true
        let fulfillExpectation = expectation(description: "fulfill")
        fulfillExpectation.isInverted = true
        let waitExpectation = expectation(description: "wait")

        let mockTest = MockTest(
            assertExpectation: assertExpectation,
            failExpectation: failExpectation,
            expectationExpectation: expectationExpectation,
            fulfillExpectation: fulfillExpectation,
            waitExpectation: waitExpectation
        )

        let recipe = Recipe<String, String> { input, _ in
            XCTAssertEqual(input, "input",
                           "assert(with:) should run the recipe")
            recipeExpectatation.fulfill()
        }

        recipe.assert(with: mockTest) { when in
            when("input").expect("expected")
        }

        wait(for: [
            expectationExpectation,
            recipeExpectatation,
            assertExpectation,
            failExpectation,
            fulfillExpectation,
            waitExpectation,
        ], timeout: 0.1, enforceOrder: true)
    }
}
