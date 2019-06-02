import XCTest

#if canImport(Result)
    import Result
#endif

extension XCTestExpectation: Fullfillable {}

extension XCTestCase: Assertable {
    public func makeExpectation(description: String) -> XCTestExpectation {
        return expectation(description: description)
    }

    public func assert<Output: Equatable>(
        actual: Result<Output, AnyError>,
        expected: Output,
        file: StaticString,
        line: UInt
    ) {
        switch actual {
        case let .success(actual):
            XCTAssertEqual(actual, expected, file: file, line: line)
        case let .failure(actual):
            XCTFail("expected \(expected), but got error: \(actual)", file: file, line: line)
        }
    }
}
