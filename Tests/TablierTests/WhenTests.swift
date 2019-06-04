@testable import Tablier
import XCTest
import Result

final class WhenTests: XCTestCase {
    func testInit() {
        let recipe = MockRecipe<String, Int>()
        let when = Recipe<String, Int>.When(recipe: recipe, input: "input")

        XCTAssertEqual(when.input, "input")

        when.recipe.testCases.append(TestCase(input: "", expected: 0, description: "", file: "", line: 0))
        XCTAssertEqual(recipe.testCases.count, 1,
                       "Appending test case to when.recipe should append it to the original recipe")
    }

    func testExpect() {
        let recipe = MockRecipe<String, Int>()
        let when = Recipe<String, Int>.When(recipe: recipe, input: "input")
        let expect = when.expect(1)

        XCTAssertEqual(expect.testCase.input, when.input)

        expect.recipe.testCases.append(TestCase(input: "", expected: 0, description: "", file: "", line: 0))
        XCTAssertEqual(recipe.testCases.count, 1,
                       "Appending test case to expect.recipe should append it to the original recipe")
    }
}
