#if swift(>=5.5) && canImport(_Concurrency)

@testable import Tablier
import XCTest

private struct StubError: Error, Equatable {}

final class AsyncRecipeTests: XCTestCase {}

// MARK: - Utility
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
private func _changeQueue() async {
    await withCheckedContinuation { c in
        DispatchQueue.global().async {
            c.resume()
        }
    }
}

// MARK: - Assert
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension AsyncRecipeTests {
    func testPassingAssert() async {
        let expectationExpectation = expectation(description: "`expectation` should be called")
        let failExpectation = expectation(description: "`fail` should NOT be called")
        failExpectation.isInverted = true
        let fulfillExpectation = expectation(description: "`fulfill` should be called")
        let waitExpectation = expectation(description: "`wait` should be called")

        let testCase = MockTestCase(
            didCallExpectation: { expectationExpectation.fulfill() },
            didCallWait: { waitExpectation.fulfill() },
            didCallFulfill: { fulfillExpectation.fulfill() }
        )

        let tester = Tester(testCase, fail: { _, _, _ in
            failExpectation.fulfill()
        })

        let recipe = AsyncRecipe<String, String> { _ in
            await _changeQueue()
            return "expected"
        }

        await recipe.assert(with: tester) {
            $0.when("input").expect("expected")
        }

        wait(for: [
            expectationExpectation,
            failExpectation,
            fulfillExpectation,
            waitExpectation,
        ], timeout: 0.1, enforceOrder: true)
    }

    func testFailingAssert() async {
        let expectationExpectation = expectation(description: "`expectation` should be called")
        let failExpectation = expectation(description: "`fail` should be called")
        let fulfillExpectation = expectation(description: "`fulfill` should be called")
        let waitExpectation = expectation(description: "`wait` should be called")

        let testCase = MockTestCase(
            didCallExpectation: { expectationExpectation.fulfill() },
            didCallWait: { waitExpectation.fulfill() },
            didCallFulfill: { fulfillExpectation.fulfill() }
        )

        let tester = Tester(testCase, fail: { _, _, _ in
            failExpectation.fulfill()
        })

        let recipe = AsyncRecipe<String, String> { _ in
            await _changeQueue()
            return "FOOBAR"
        }

        await recipe.assert(with: tester) {
            $0.when("input").expect("expected")
        }

        wait(for: [
            expectationExpectation,
            failExpectation,
            fulfillExpectation,
            waitExpectation,
        ], timeout: 0.1, enforceOrder: true)
    }

    func testErrorAssert() async {
        let expectationExpectation = expectation(description: "`expectation` should be called")
        let failExpectation = expectation(description: "`fail` should be called")
        let fulfillExpectation = expectation(description: "`fulfill` should be called")
        let waitExpectation = expectation(description: "`wait` should be called")

        let testCase = MockTestCase(
            didCallExpectation: { expectationExpectation.fulfill() },
            didCallWait: { waitExpectation.fulfill() },
            didCallFulfill: { fulfillExpectation.fulfill() }
        )

        let tester = Tester(testCase, fail: { _, _, _ in failExpectation.fulfill() })

        let recipe = AsyncRecipe<String, String> { _ in
            await _changeQueue()
            throw StubError()
        }

        await recipe.assert(with: tester) {
            $0.when("input").expect("expected")
        }

        wait(for: [
            expectationExpectation,
            failExpectation,
            fulfillExpectation,
            waitExpectation,
        ], timeout: 0.1, enforceOrder: true)
    }

    func testTestCaseReleased() async {
        let expectationExpectation = expectation(description: "`expectation` should NOT be called")
        expectationExpectation.isInverted = true
        let failExpectation = expectation(description: "`fail` should NOT be called")
        failExpectation.isInverted = true
        let fulfillExpectation = expectation(description: "`fulfill` should NOT be called")
        fulfillExpectation.isInverted = true
        let waitExpectation = expectation(description: "`wait` should NOT be called")
        waitExpectation.isInverted = true

        var testCase: MockTestCase? = MockTestCase(
            didCallExpectation: { expectationExpectation.fulfill() },
            didCallWait: { waitExpectation.fulfill() },
            didCallFulfill: { fulfillExpectation.fulfill() }
        )

        let tester = Tester(testCase!, fail: { _, _, _ in failExpectation.fulfill() })

        let recipe = AsyncRecipe<String, String> { _ in
            throw StubError()
        }

        // Release test case
        testCase = nil

        await recipe.assert(with: tester) {
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

#endif
