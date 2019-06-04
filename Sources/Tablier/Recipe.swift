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
