@testable import Tablier
import XCTest

#if canImport(Result)
    import Result
#endif

struct Foo: Equatable {}
struct MockError: Error, Equatable {}

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
                throw MockError()
            }

            failureRecipe.recipe(Foo()) { result in
                XCTAssertEqual(result.error?.error as? MockError, MockError(),
                               "Sync initalizer should pass closure to async initializer")
            }
        }
    }

    func testInitAsync() {
        do {
            let recipe = Recipe<Foo, Foo> { _, completion in
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
}
