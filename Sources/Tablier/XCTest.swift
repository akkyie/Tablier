import XCTest

extension XCTestCase: XCTestCaseProtocol {}

extension XCTestExpectation: XCTestExpectationProtocol {}

#if os(Linux)

public protocol XCTestCaseProtocol: AnyObject {
    associatedtype ExpectationType: XCTestExpectationProtocol

    func wait(for expectations: [ExpectationType], timeout: TimeInterval, enforceOrder: Bool,
              file: StaticString, line: Int)

    func expectation(description: String, file: StaticString, line: Int) -> ExpectationType
}

public protocol XCTestExpectationProtocol: AnyObject {
    func fulfill(_ file: StaticString, line: Int)
}

#elseif os(macOS) || os(iOS) || os(tvOS)

public protocol XCTestCaseProtocol: AnyObject {
    associatedtype ExpectationType: XCTestExpectationProtocol

    func wait(for expectations: [ExpectationType], timeout: TimeInterval, enforceOrder: Bool)
    func expectation(description: String) -> ExpectationType
}

public protocol XCTestExpectationProtocol: AnyObject {
    func fulfill()
}

#endif

open class Tester<TestCase: XCTestCaseProtocol> {
    let fail: (_ message: String, _ file: StaticString, _ line: UInt) -> Void

    let wait: (_ expectations: [TestCase.ExpectationType], _ timeout: TimeInterval, _ enforceOrder: Bool,
               _ file: StaticString, _ line: UInt) -> Void

    let expect: (_ description: String, _ file: StaticString, _ line: UInt) -> TestCase.ExpectationType?

    let fulfill: (_ expectation: TestCase.ExpectationType, _ file: StaticString, _ line: UInt) -> Void

    init(_ testCase: TestCase, fail: @escaping (String, StaticString, UInt) -> Void = XCTFail) {
        #if os(Linux)

        self.fail = fail

        self.wait = { [weak testCase] expectations, timeout, enforceOrder, file, line in
            testCase?.wait(for: expectations, timeout: timeout, enforceOrder: enforceOrder, file: file, line: Int(line))
        }

        self.expect = { [weak testCase] description, file, line in
            testCase?.expectation(description: description, file: file, line: Int(line))
        }

        self.fulfill = { expectation, file, line in expectation.fulfill(file, line: Int(line)) }

        #elseif os(macOS) || os(iOS) || os(tvOS)

        self.fail = fail

        self.wait = { [weak testCase] expectations, timeout, enforceOrder, _, _ in
            testCase?.wait(for: expectations, timeout: timeout, enforceOrder: enforceOrder)
        }

        self.expect = { [weak testCase] description, _, _ in
            testCase?.expectation(description: description)
        }

        self.fulfill = { expectation, _, _ in expectation.fulfill() }

        #endif
    }

    open func assertionDescription(for actual: Any, expected: Any, descriptions: [String]) -> String {
        let descriptions = [
            "expected: \(defaultDescription(for: expected))",
            "actual: \(defaultDescription(for: actual))",
            ] + descriptions
        return descriptions.joined(separator: " - ")
    }

    open func errorDescription(for error: Error, expected: Any, descriptions: [String]) -> String {
        let descriptions = [
            "expected: \(defaultDescription(for: expected))",
            "error: \(defaultDescription(for: error))",
            ] + descriptions
        return descriptions.joined(separator: " - ")
    }

    private func defaultDescription(for value: Any) -> String {
        switch value {
        case let error as Error:
            return "\"" + error.localizedDescription + "\""
        case let value as CustomDebugStringConvertible:
            return value.debugDescription
        case let value as CustomStringConvertible:
            return value.description
        default:
            return String(describing: value)
        }
    }
}
