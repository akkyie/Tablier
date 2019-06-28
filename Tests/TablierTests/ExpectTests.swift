@testable import Tablier
import XCTest

final class ExpectTests: XCTestCase {
    func testExpect() {
        let inputs = ["a", "b", "c"]
        let expected = "expected"
        let recipe = MockRecipe<String, String>()
        do {
            let expect = Recipe<String, String>.Expect(
                recipe: AnyRecipe(recipe),
                inputs: inputs,
                expected: expected,
                descriptions: ["description"],
                file: "file",
                line: 12345
            )
            _ = expect.withDescription("A").withDescription("B")
            _ = expect.withDescription("C")
            // expect gets deinitialized
        }

        XCTAssertEqual(recipe.testCases.map { $0.input }, inputs)
        XCTAssertEqual(recipe.testCases.map { $0.expected }, Array(repeating: expected, count: inputs.count))
        XCTAssertEqual(recipe.testCases.map { $0.descriptions },
                       Array(repeating: ["description", "A", "B", "C"], count: inputs.count))
    }

    func testOmit() {
        let inputs = ["a", "b", "c"]
        let expected = "expected"
        let recipe = MockRecipe<String, String>()
        do {
            let expect = Recipe<String, String>.Expect(
                recipe: AnyRecipe(recipe),
                inputs: inputs,
                expected: expected,
                descriptions: ["description"],
                file: "file",
                line: 12345
            )

            expect.omit()
            // expect gets deinitialized
        }

        XCTAssert(recipe.testCases.isEmpty)
    }
}
