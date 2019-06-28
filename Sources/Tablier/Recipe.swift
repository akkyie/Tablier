import struct Foundation.TimeInterval

protocol RecipeType: AnyObject {
    associatedtype Input
    associatedtype Output: Equatable

    var testCases: [Recipe<Input, Output>.TestCase] { get set }
}

public final class Recipe<Input, Output: Equatable>: RecipeType {
    public static var defaultTimeout: TimeInterval { return 5 }

    public typealias Completion = (Output?, Error?) -> Void
    public typealias RecipeClosure =
        (Input, _ completion: @escaping Completion, _ file: StaticString, _ line: UInt) -> Void
    public typealias SyncRecipeClosure =
        (Input, _ file: StaticString, _ line: UInt) throws -> Output

    var testCases: [TestCase] = []

    let recipe: RecipeClosure
    let timeout: TimeInterval

    public init(description: String = "", timeout: TimeInterval = defaultTimeout,
                async recipe: @escaping RecipeClosure) {
        self.recipe = recipe
        self.timeout = timeout
    }

    public convenience init(description: String = "",
                            sync recipe: @escaping SyncRecipeClosure) {
        self.init(description: description, timeout: 0, async: { input, completion, file, line in
            do {
                let actual = try recipe(input, file, line)
                completion(actual, nil)
            } catch let error {
                completion(nil, error)
            }
        })
    }
}

extension Recipe {
    public func assert<TestCase: XCTestCaseProtocol>(
        with testCase: TestCase, file: StaticString = #file, line: UInt = #line,
        assertion makeTestCases: (_ asserter: Expecter) -> Void
    ) {
        assert(with: Tester(testCase), file: file, line: line, assertion: makeTestCases)
    }

    public func assert<TestCase: XCTestCaseProtocol>(
        with tester: Tester<TestCase>, file: StaticString = #file, line: UInt = #line,
        assertion makeTestCases: (_ asserter: Expecter) -> Void
    ) {
        let expecter = Expecter(recipe: AnyRecipe(self))
        makeTestCases(expecter)

        var expectations: [TestCase.ExpectationType] = []

        for testCase in testCases {
            let (expected, descriptions) = (testCase.expected, testCase.descriptions)
            let description = descriptions.joined(separator: " - ")

            guard let expectation = tester.expect(description, file, line) else {
                print("[Tablier] \(#file):\(#line): the test case got released before the assertion was completed")
                return
            }

            let handleResult = { (actual: Output?, error: Error?) -> Void in
                switch (actual, error) {
                case let (actual?, nil):
                    guard actual != expected else { break }

                    let description = tester.assertionDescription(
                        for: actual,
                        expected: expected,
                        descriptions: descriptions
                    )

                    tester.fail(description, testCase.file, testCase.line)
                case let (nil, error?):
                    let description = tester.assertionDescription(
                        for: error,
                        expected: expected,
                        descriptions: descriptions
                    )

                    tester.fail(description, testCase.file, testCase.line)
                case (_?, _?):
                    tester.fail("either hand of completion parameters should be nil", testCase.file, testCase.line)
                case (nil, nil):
                    tester.fail("either hand of completion parameter should be not nil", testCase.file, testCase.line)
                }

                tester.fulfill(expectation, testCase.file, testCase.line)
            }

            recipe(testCase.input, handleResult, testCase.file, testCase.line)

            expectations.append(expectation)
        }

        tester.wait(expectations, timeout, false, file, line)
    }
}
