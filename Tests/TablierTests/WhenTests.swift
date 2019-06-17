@testable import Tablier
import XCTest

#if canImport(Result)
import Result
#endif

final class WhenTests: XCTestCase {
    func testInit() {
        do {
            let recipe = MockRecipe<String, Int>()
            let when = Recipe<String, Int>.When(recipe: recipe, inputs: ["input"])

            XCTAssertEqual(when.inputs, ["input"])
            XCTAssertEqual(recipe.testCases.count, 0)
        }

        do {
            let recipe = MockRecipe<String, Int>()
            let when = Recipe<String, Int>.When(recipe: recipe, inputs: ["a", "b"])

            XCTAssertEqual(when.inputs, ["a", "b"])
            XCTAssertEqual(recipe.testCases.count, 0)
        }
    }

    func testDeinit() {
        let recipe = MockRecipe<String, Int>()
        let testCaseStub = TestCase<String, Int>(
            input: "input",
            filter: { AnyEquatable($0) },
            expected: AnyEquatable(123),
            description: "description",
            file: "file",
            line: 999
        )

        var when: Recipe<String, Int>.When?
        do {
            when = Recipe<String, Int>.When(recipe: recipe, inputs: [])
            when?.testCases = [testCaseStub]
            when = nil
        }

        XCTAssertEqual(recipe.testCases.count, 1,
                       "Recipe.When should append its testcase to the recipe on its deinit")
    }

    func testExpect() {
        struct Output: Equatable {
            let value: Int
        }

        do { // without description, using KeyPath
            let recipe = MockRecipe<String, Output>()
            let when = Recipe<String, Output>.When(recipe: recipe, inputs: ["input"])

            when.expect(\.value, 123)

            XCTAssertEqual(when.testCases.count, 1)
            XCTAssertEqual(when.testCases.first?.input, "input")
            XCTAssertEqual(when.testCases.first?.expected, AnyEquatable(123))
            XCTAssertEqual(when.testCases.first?.description, "")
        }

        do { // with description, using KeyPath
            let recipe = MockRecipe<String, Output>()
            let when = Recipe<String, Output>.When(recipe: recipe, inputs: ["input"])

            when.expect(\.value, 123, description: "description")

            XCTAssertEqual(when.testCases.count, 1)
            XCTAssertEqual(when.testCases.first?.input, "input")
            XCTAssertEqual(when.testCases.first?.expected, AnyEquatable(123))
            XCTAssertEqual(when.testCases.first?.description, "description")
        }

        do { // no KeyPath use
            let recipe = MockRecipe<String, Output>()
            let when = Recipe<String, Output>.When(recipe: recipe, inputs: ["input"])

            when.expect(Output(value: 123), description: "description")

            XCTAssertEqual(when.testCases.count, 1)
            XCTAssertEqual(when.testCases.first?.input, "input")
            XCTAssertEqual(when.testCases.first?.expected, AnyEquatable(Output(value: 123)))
            XCTAssertEqual(when.testCases.first?.description, "description")
        }

        do { // multiple inputs
            let recipe = MockRecipe<String, Output>()
            let when = Recipe<String, Output>.When(recipe: recipe, inputs: ["a", "b", "c"])

            when.expect(Output(value: 123), description: "description")

            guard when.testCases.count == 3 else {
                XCTFail("the number of when.testCases should be same as the inputs")
                return
            }

            XCTAssertEqual(when.testCases[0].input, "a")
            XCTAssertEqual(when.testCases[0].expected, AnyEquatable(Output(value: 123)))
            XCTAssertEqual(when.testCases[0].description, "description")
            XCTAssertEqual(when.testCases[1].input, "b")
            XCTAssertEqual(when.testCases[1].expected, AnyEquatable(Output(value: 123)))
            XCTAssertEqual(when.testCases[1].description, "description")
            XCTAssertEqual(when.testCases[2].input, "c")
            XCTAssertEqual(when.testCases[2].expected, AnyEquatable(Output(value: 123)))
            XCTAssertEqual(when.testCases[2].description, "description")
        }
    }

    func testOmit() {
        struct Output: Equatable {
            let value: Int
        }

        let recipe = MockRecipe<String, Output>()
        let when = Recipe<String, Output>.When(recipe: recipe, inputs: ["input"])

        when.expect(\.value, 123)
        XCTAssertEqual(when.testCases.count, 1)

        when.expect(\.value, 456)
        XCTAssertEqual(when.testCases.count, 2)

        when.expect(\.value, 789)
        XCTAssertEqual(when.testCases.count, 3)

        when.omit()
        XCTAssertEqual(when.testCases.count, 0, "omit() of Recipe.When should reset its testCases")
    }
}
