import XCTest

extension XCTestExpectation: Fullfillable {}

extension XCTestCase: Assertable {
    public func makeExpectation(description: String) -> XCTestExpectation {
        return expectation(description: description)
    }

    public func assert<Output: Equatable>(actual: Output, expected: Output, file: StaticString, line: UInt) {
        XCTAssertEqual(actual, expected, file: file, line: line)
    }
}
