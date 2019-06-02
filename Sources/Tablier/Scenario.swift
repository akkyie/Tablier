import struct Foundation.TimeInterval

#if swift(>=5)
#else
enum Result<Success, Failure> {
    case success(Success)
    case failure(Failure)

    init(catching body: () throws -> Success) {
        do {
            let success = try body()
            self = .success(success)
        } catch let error {
            self = .failure(error)
        }
    }
}

extension Result: Equatable where Success: Equatable, Failure: Equatable {}
#endif

public final class Scenario<Input, Output: Equatable> {
    public static var defaultTimeout: TimeInterval { return 5 }

    public typealias Completion = (Result<Output, Error>) -> Void

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
            let result = Result { try scenario(input) }
            return completion(result)
        })
    }
}

extension Scenario where Output: Equatable {
    public func assert<T: Assertable>(with assertion: T) {
        let expectations: [T.Expectation] = testCases.map { testCase in
            let expectation = assertion.makeExpectation(description: description)
            scenario(testCase.input) { actual in
                assertion.assert(actual: actual, expected: testCase.expected, file: testCase.file, line: testCase.line)
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

extension Scenario {
    public struct TestCase {
        let input: Input
        let expected: Output
        let file: StaticString
        let line: UInt
    }
}
