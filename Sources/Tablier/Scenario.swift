import struct Foundation.TimeInterval

#if canImport(Result)
    import Result
#endif

public final class Scenario<Input, Output: Equatable> {
    public static var defaultTimeout: TimeInterval { return 5 }

    public typealias Completion = (Result<Output, AnyError>) -> Void

    public typealias SyncScenario = (Input) throws -> Output
    public typealias AsyncScenario = (Input, _ completion: Completion) -> Void

    var testCases: [TestCase] = []

    let scenario: AsyncScenario
    let description: String
    let timeout: TimeInterval

    public init(description: String = "", timeout: TimeInterval = defaultTimeout, async scenario: @escaping AsyncScenario) {
        self.scenario = scenario
        self.description = description
        self.timeout = timeout
    }

    public convenience init(description: String = "", sync scenario: @escaping SyncScenario) {
        self.init(description: description, timeout: 0, async: { input, completion in
            let result = Result<Output, AnyError> { try scenario(input) }
            return completion(result)
        })
    }
}

extension Scenario where Output: Equatable {
    public func assert<T: Testable>(with testable: T, file: StaticString = #file, line: UInt = #line) {
        let expectations: [T.Expectation] = testCases.map { testCase in
            let expectation = testable.expectation(description: description, file: testCase.file, line: testCase.line)
            scenario(testCase.input) { actual in
                testable.assert(actual: actual, expected: testCase.expected, file: testCase.file, line: testCase.line)
                expectation.fulfill(testCase.file, line: Int(testCase.line))
            }
            return expectation
        }
        testable.wait(for: expectations, timeout: timeout, enforceOrder: false, file: file, line: line)
    }
}

extension Scenario {
    public func when(input: Input) -> Condition {
        return Condition(scenario: self, input: input)
    }
}

extension Scenario {
    public struct Condition {
        let scenario: Scenario
        let input: Input

        public func expect(_ expected: Output, file: StaticString = #file, line: UInt = #line) {
            let testcase = TestCase(input: input, expected: expected, file: file, line: line)
            scenario.testCases.append(testcase)
        }
    }
}

extension Scenario {
    public struct TestCase {
        let input: Input
        let expected: Output
        let file: StaticString
        let line: UInt
    }
}
