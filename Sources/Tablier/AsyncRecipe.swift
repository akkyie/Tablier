import struct Foundation.TimeInterval

#if swift(>=5.5) && canImport(_Concurrency)

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public final class AsyncRecipe<Input, Output: Equatable>: RecipeType {
    public static var defaultTimeout: TimeInterval { return 5 }

    public typealias RecipeClosure =
    (Input, _ file: StaticString, _ line: UInt) async throws -> Output

    var testCases: [TestCase<Input, Output>] = []

    let recipe: RecipeClosure
    let timeout: TimeInterval

    // MARK: Initializers

    public init(
        timeout: TimeInterval = defaultTimeout,
        async recipe: @escaping RecipeClosure
    ) {
        self.recipe = recipe
        self.timeout = timeout
    }

    public init(
        timeout: TimeInterval = defaultTimeout,
        async recipe: @escaping (Input) async throws -> Output
    ) {
        self.recipe = { input, _, _ in try await recipe(input) }
        self.timeout = timeout
    }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension AsyncRecipe {
    public func assert<TestCase: XCTestCaseProtocol>(
        with testCase: TestCase, file: StaticString = #file, line: UInt = #line,
        assertion makeTestCases: (_ asserter: Expecter<Input, Output>) -> Void
    ) async {
        await assert(with: Tester(testCase), file: file, line: line, assertion: makeTestCases)
    }

    public func assert<TestCase: XCTestCaseProtocol>(
        with tester: Tester<TestCase>, file: StaticString = #file, line: UInt = #line,
        assertion makeTestCases: (_ asserter: Expecter<Input, Output>) -> Void
    ) async {
        let expecter = Expecter(recipe: AnyRecipe(self))
        makeTestCases(expecter)

        var expectations: [TestCase.ExpectationType] = []

        for testCase in testCases {
            let (expected, descriptions) = (testCase.expected, testCase.descriptions)
            let description = descriptions.joined(separator: " - ")

            guard let expectation = tester.expect(description, file, line) else {
                print("[Tablier] \(#file):\(#line): the test case got released before the assertion completes")
                return
            }

            do {
                let actual = try await recipe(testCase.input, testCase.file, testCase.line)

                if actual != expected {
                    let description = tester.assertionDescription(
                        for: actual,
                        expected: expected,
                        descriptions: descriptions
                    )

                    tester.fail(description, testCase.file, testCase.line)
                }
            } catch let error {
                let description = tester.assertionDescription(
                    for: error,
                    expected: expected,
                    descriptions: descriptions
                )

                tester.fail(description, testCase.file, testCase.line)
            }

            tester.fulfill(expectation, testCase.file, testCase.line)

            expectations.append(expectation)
        }

        tester.wait(expectations, timeout, false, file, line)
    }
}

#endif
