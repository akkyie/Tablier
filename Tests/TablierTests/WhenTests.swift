@testable import Tablier
import XCTest

final class WhenTests: XCTestCase {
    func testWhen() {
        let inputs = ["a", "b", "c"]

        let recipe = MockRecipe<String, String>()
        let when = Recipe<String, String>.When(recipe: AnyRecipe(recipe), inputs: inputs, file: "file", line: 12345)
        XCTAssertEqual(when.inputs, inputs)
        XCTAssertEqual(when.descriptions, [])

        _ = when.withDescription("first description")
        XCTAssertEqual(when.inputs, inputs)
        XCTAssertEqual(when.descriptions, ["first description"])

        _ = when.withDescription("second description")
        XCTAssertEqual(when.inputs, inputs)
        XCTAssertEqual(when.descriptions, ["first description", "second description"])

        let expect = when.expect("expected")
        XCTAssertEqual(expect.inputs, when.inputs)
        XCTAssertEqual(expect.descriptions, when.descriptions)
    }
}
