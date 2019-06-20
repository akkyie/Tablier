import XCTest

extension XCTestExpectation: Fulfillable {}

extension XCTestCase: Assertable {
    open func fail(description: String, file: StaticString, line: UInt) {
        XCTFail(description, file: file, line: line)
    }
}

extension XCTestCase: Waitable {
    public typealias Expectation = XCTestExpectation

    #if os(macOS)
    public func expectation(description: String, file: StaticString, line: UInt) -> XCTestExpectation {
        return expectation(description: description)
    }
    #else
    public func expectation(description: String, file: StaticString, line: UInt) -> XCTestExpectation {
        return XCTestExpectation(description: description, file: file, line: Int(line))
    }
    #endif
}

// Shim for the difference between swift-corelibs-xctest and XCTest
#if os(macOS)
extension XCTestExpectation {
    public func fulfill(_ file: StaticString, line: Int) {
        fulfill()
    }
}

extension XCTestCase {
    public func wait(for expectations: [XCTestExpectation], timeout: TimeInterval, enforceOrder: Bool,
                     file: StaticString, line: UInt) {
        wait(for: expectations, timeout: timeout, enforceOrder: enforceOrder)
    }
}
#else
extension XCTestCase {
    public func wait(for expectations: [XCTestExpectation], timeout: TimeInterval, enforceOrder: Bool,
                     file: StaticString, line: UInt) {
        wait(for: expectations, timeout: timeout, enforceOrder: enforceOrder, file: file, line: Int(line))
    }
}
#endif
