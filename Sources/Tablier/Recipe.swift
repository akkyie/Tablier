import struct Foundation.TimeInterval

#if canImport(Result)
    import Result
#endif

public final class Recipe<Input, Output: Equatable> {
    public static var defaultTimeout: TimeInterval { return 5 }

    public typealias Completion = (Result<Output, AnyError>) -> Void

    public typealias RecipeClosure = (Input, _ completion: Completion) -> Void

    let recipe: RecipeClosure
    let description: String
    let timeout: TimeInterval

    public init(description: String = "", timeout: TimeInterval = defaultTimeout, async recipe: @escaping RecipeClosure) {
        self.recipe = recipe
        self.description = description
        self.timeout = timeout
    }

    public convenience init(description: String = "", sync recipe: @escaping (Input) throws -> Output) {
        self.init(description: description, timeout: 0, async: { input, completion in
            let result = Result<Output, AnyError> { try recipe(input) }
            return completion(result)
        })
    }
}

extension Recipe {
    public func assert<T: Testable>(with testable: T, file: StaticString = #file, line: UInt = #line, assertion: (_ when: (Input) -> When) -> Void) {
        var testCases: [TestCase] = []

        let when: (Input) -> When = { input in When(testCases: &testCases, recipe: self, input: input) }
        assertion(when)

        let expectations: [T.Expectation] = testCases.map { testCase in
            let expectation = testable.expectation(description: description, file: testCase.file, line: testCase.line)
            recipe(testCase.input) { actual in
                testable.assert(actual: actual, expected: testCase.expected, file: testCase.file, line: testCase.line)
                expectation.fulfill(testCase.file, line: Int(testCase.line))
            }
            return expectation
        }

        testable.wait(for: expectations, timeout: timeout, enforceOrder: false, file: file, line: line)
    }
}

extension Recipe {
    public final class When {
        var testCases: [TestCase]
        let input: Input

        init(testCases: inout [TestCase], recipe: Recipe<Input, Output>, input: Input) {
            self.testCases = testCases
            self.input = input
        }

        @discardableResult
        func expect(_ expected: Output, file: StaticString = #file, line: UInt = #line) -> Expect {
            return Expect(testCases: &testCases, input: input, expected: expected, file: file, line: line)
        }
    }

    public final class Expect {
        var testCases: [TestCase]
        var testCase: TestCase

        init(testCases: inout [TestCase], input: Input, expected: Output, file: StaticString, line: UInt) {
            self.testCases = testCases
            self.testCase = TestCase(input: input, expected: expected, description: "", file: file, line: line)
        }

        func with(description: String) {
            testCase.description = description
        }

        deinit {
            testCases.append(testCase)
        }
    }
}

extension Recipe {
    public struct TestCase {
        let input: Input
        let expected: Output
        var description: String
        let file: StaticString
        let line: UInt
    }
}
