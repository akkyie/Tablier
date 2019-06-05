import XCTest

#if canImport(Result)
    import Result
#endif

extension XCTestExpectation: Fullfillable {}

extension XCTestCase: Assertable {
    public func assert<Output: Equatable>(
        actual: Result<Output, TablierError>,
        expected: Output,
        description: String,
        file: StaticString,
        line: UInt
    ) {
        switch actual {
        case let .success(actual):
            XCTAssertEqual(actual, expected, description, file: file, line: line)
        case let .failure(actual):
            let message = ["expected \(expected), but got error: \(actual)", description].joined(separator: " - ")
            XCTFail(message, file: file, line: line)
        }
    }
}

extension XCTestCase: Waitable {
    public typealias Expectation = XCTestExpectation

    public func expectation(description: String, file: StaticString, line: UInt) -> XCTestExpectation {
        #if os(macOS)
        return expectation(description: description)
        #else
        return XCTestExpectation(description: description, file: file, line: Int(line))
        #endif
    }
}

// Shim for the difference between swift-corelibs-xctest and XCTest
#if os(macOS)
extension XCTestExpectation {
    public func fulfill(_ file: StaticString, line: Int) {
        fulfill()
    }
}

extension XCTestCase {
    public func wait(for expectations: [XCTestExpectation], timeout: TimeInterval, enforceOrder: Bool, file: StaticString, line: UInt) {
        wait(for: expectations, timeout: timeout, enforceOrder: enforceOrder)
    }
}
#else
extension XCTestCase {
    public func wait(for expectations: [XCTestExpectation], timeout: TimeInterval, enforceOrder: Bool, file: StaticString, line: UInt) {
        wait(for: expectations, timeout: timeout, enforceOrder: enforceOrder, file: file, line: Int(line))
    }
}
#endif
