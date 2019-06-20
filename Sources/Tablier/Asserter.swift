import struct Foundation.TimeInterval

open class Asserter<Test: Testable> {
    let test: Test

    init(_ assertable: Test) {
        self.test = assertable
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

    open func fail(description: String, file: StaticString, line: UInt) {
        test.fail(description: description, file: file, line: line)
    }

    open func expectation(description: String, file: StaticString, line: UInt) -> Test.Expectation {
        return test.expectation(description: description, file: file, line: line)
    }

    open func wait(for expectations: [Test.Expectation], timeout: TimeInterval, enforceOrder: Bool,
                   file: StaticString, line: UInt) {
        return test.wait(for: expectations, timeout: timeout, enforceOrder: enforceOrder, file: file, line: line)
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
