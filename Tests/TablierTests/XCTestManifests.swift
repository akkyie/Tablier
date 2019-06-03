import XCTest

extension ExampleTestCase {
    static let __allTests = [
        ("testJSONDecoder", testJSONDecoder),
    ]
}

extension ScenarioTests {
    static let __allTests = [
        ("testAsync", testAsync),
        ("testCondition", testCondition),
        ("testExpectation", testExpectation),
        ("testExpectFailure", testExpectFailure),
        ("testExpectSuccess", testExpectSuccess),
        ("testSync", testSync),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ExampleTestCase.__allTests),
        testCase(ScenarioTests.__allTests),
    ]
}
#endif
