import struct Foundation.TimeInterval

public typealias TestCase<Input, Output> = (input: Input, expected: Output, file: StaticString, line: UInt)

public final class Scenario<Input, Output> {
    public static var defaultTimeout: TimeInterval { return 5 }

    public typealias Completion = (Output) -> Void

    public typealias SyncScenario = (Input) -> Output
    public typealias AsyncScenario = (Input, _ completion: Completion) -> Void

    var testCases: [TestCase<Input, Output>] = []

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
            let result = scenario(input)
            return completion(result)
        })
    }
}

extension Scenario where Output: Equatable {
    public func assert<T: Assertable>(with assertion: T) {
        let expectations: [T.Expectation] = testCases.map { (input, expected, file, line) in
            let expectation = assertion.makeExpectation(description: description)
            scenario(input) { actual in
                assertion.assert(actual: actual, expected: expected, file: file, line: line)
                expectation.fulfill()
            }
            return expectation
        }
        assertion.wait(for: expectations, timeout: timeout)
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
