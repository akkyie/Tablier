@testable import Tablier
import XCTest
import Result

final class ExpectTests: XCTestCase {
    func testInit() {
        let recipe = MockRecipe<String, Int>()
        let expect = Recipe<String, Int>.Expect(
            recipe: recipe,
            input: "123",
            expected: 123,
            file: "file",
            line: 999
        )

        XCTAssertEqual(expect.testCase.input, "123")
        XCTAssertEqual(expect.testCase.expected, 123)
        XCTAssertEqual(expect.testCase.description, "")
        XCTAssertEqual("\(expect.testCase.file)", "file")
        XCTAssertEqual(expect.testCase.line, 999)
    }

    func testDeinit() {
        let recipe = MockRecipe<String, Int>()

        do {
            _ = Recipe<String, Int>.Expect(
                recipe: recipe,
                input: "123",
                expected: 123,
                file: "file",
                line: 999
            )
        }

        XCTAssertEqual(recipe.testCases.count, 1)
        guard let testCase = recipe.testCases.first else {
            XCTFail("Expect should modify test cases after its deinitialization")
            return
        }

        XCTAssertEqual(testCase.input, "123")
        XCTAssertEqual(testCase.expected, 123)
        XCTAssertEqual(testCase.description, "")
        XCTAssertEqual(String(describing: testCase.file), "file")
        XCTAssertEqual(testCase.line, 999)
    }

    func testWith() {
        let recipe = MockRecipe<String, Int>()

        do {
            let expect = Recipe<String, Int>.Expect(
                recipe: recipe,
                input: "123",
                expected: 123,
                file: "file",
                line: 999
            )

            expect.with(description: "description")
        }

        guard let testCase = recipe.testCases.first else {
            XCTFail("Expect should modify test cases after its deinitialization")
            return
        }

        XCTAssertEqual(testCase.description, "description",
                       "with(description:) should update description")
    }
}
