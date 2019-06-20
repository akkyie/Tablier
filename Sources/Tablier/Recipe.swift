import struct Foundation.TimeInterval

protocol RecipeType: AnyObject {
    associatedtype Input
    associatedtype Output: Equatable

    var testCases: [TestCase<Input, Output>] { get set }
}

public final class Recipe<Input, Output: Equatable>: RecipeType {
    public static var defaultTimeout: TimeInterval { return 5 }

    public typealias Completion = (Output?, Error?) -> Void
    public typealias RecipeClosure = (Input, _ completion: @escaping Completion) -> Void

    var testCases: [TestCase<Input, Output>] = []

    let recipe: RecipeClosure
    let timeout: TimeInterval

    public init(description: String = "", timeout: TimeInterval = defaultTimeout,
                async recipe: @escaping RecipeClosure) {
        self.recipe = recipe
        self.timeout = timeout
    }

    public convenience init(description: String = "",
                            sync recipe: @escaping (Input) throws -> Output) {
        self.init(description: description, timeout: 0, async: { input, completion in
            do {
                let actual = try recipe(input)
                completion(actual, nil)
            } catch let error {
                completion(nil, error)
            }
        })
    }
}

extension Recipe {
    public func assert<T: Testable>(with testable: T, file: StaticString = #file, line: UInt = #line,
                                    assertion makeTestCases: (_ asserter: Expecter<Input, Output>) -> Void) {
        assert(with: Asserter(testable), file: file, line: line, assertion: makeTestCases)
    }

    public func assert<T: Testable>(with asserter: Asserter<T>, file: StaticString = #file, line: UInt = #line,
                                    assertion makeTestCases: (_ asserter: Expecter<Input, Output>) -> Void) {
        let expecter = Expecter<Input, Output>(recipe: AnyRecipe(self))
        makeTestCases(expecter)

        let expectations: [T.Expectation] = testCases.map { testCase in
            let (expected, descriptions) = (testCase.expected, testCase.descriptions)
            let description = descriptions.joined(separator: " - ")
            let expectation = asserter.expectation(description: description, file: file, line: line)

            recipe(testCase.input) { (actual, error) in
                switch (actual, error) {
                case let (actual?, nil):
                    guard actual != expected else { break }

                    let description = asserter.assertionDescription(
                        for: actual,
                        expected: expected,
                        descriptions: descriptions
                    )

                    asserter.fail(
                        description: description,
                        file: testCase.file,
                        line: testCase.line
                    )
                case let (nil, error?):
                    let description = asserter.assertionDescription(
                        for: error,
                        expected: expected,
                        descriptions: descriptions
                    )

                    asserter.fail(
                        description: description,
                        file: testCase.file,
                        line: testCase.line
                    )
                case (_?, _?):
                    asserter.fail(
                        description: "either hand of completion parameters should be nil",
                        file: testCase.file,
                        line: testCase.line
                    )
                case (nil, nil):
                    asserter.fail(
                        description: "either hand of completion parameter should be not nil",
                        file: testCase.file,
                        line: testCase.line
                    )
                }

                expectation.fulfill(testCase.file, line: Int(testCase.line))
            }

            return expectation
        }

        asserter.wait(for: expectations, timeout: timeout, enforceOrder: false, file: file, line: line)
    }
}
