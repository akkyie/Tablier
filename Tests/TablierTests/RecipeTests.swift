@testable import Tablier
import XCTest

#if canImport(Result)
    import Result
#endif

private struct Foo: Equatable {}

struct MockExpectation: Fullfillable {
    let mockFullfill: () -> Void
    func fulfill(_: StaticString, line _: Int) { mockFullfill() }
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

final class RecipeTests: XCTestCase {
    func testSync() {
        let recipe = Recipe<String, Int> { _ in
            XCTFail("initializer should not run the actual recipe")
            return 0
        }

        XCTAssertEqual(recipe.timeout, 0)
    }

    func testAsync() {
        do {
            let recipe = Recipe<String, Int> { _, completion in
                XCTFail("initializer should not run the actual recipe")
                completion(.success(0))
            }

            XCTAssertEqual(recipe.timeout, 5,
                           "init(async:) should have default timeout")
        }

        do {
            let recipe = Recipe<String, Int>(timeout: 100) { _, completion in
                XCTFail("initializer should not run the actual recipe")
                completion(.success(0))
            }

            XCTAssertEqual(recipe.timeout, 100,
                           "timeout should be configurable")
        }
    }
}
