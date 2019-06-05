import struct Foundation.TimeInterval
import Result

protocol RecipeType: AnyObject {
    associatedtype Input
    associatedtype Output: Equatable
    var testCases: [TestCase<Input, Output>] { get set }
}

public final class Recipe<Input, Output: Equatable>: RecipeType {
    public static var defaultTimeout: TimeInterval { return 5 }

    public typealias Completion = (Result<Output, TablierError>) -> Void
    public typealias RecipeClosure = (Input, _ completion: Completion) -> Void

    let recipe: RecipeClosure
    let timeout: TimeInterval

    var testCases: [TestCase<Input, Output>] = []

    public init(description: String = "", timeout: TimeInterval = defaultTimeout, async recipe: @escaping RecipeClosure) {
        self.recipe = recipe
        self.timeout = timeout
    }

    public convenience init(description: String = "", sync recipe: @escaping (Input) throws -> Output) {
        self.init(description: description, timeout: 0, async: { input, completion in
            let actual = Result<Output, TablierError>(catching: {
                let actual: Output
                do { actual = try recipe(input) }
                catch let error { throw TablierError(error) }
                return actual
            })
            return completion(actual)
        })
    }
}

extension Recipe {
    public func assert<T: Testable>(
        with testable: T,
        file: StaticString = #file,
        line: UInt = #line,
        assertion makeTestCases: (_ when: (Input) -> When) -> Void
    ) {
        let when: (Input) -> When = { input in When(recipe: self, input: input) }
        makeTestCases(when)

        let expectations: [T.Expectation] = testCases.map { testCase in
            let (description, file, line) = (testCase.description, testCase.file, testCase.line)
            let expectation = testable.expectation(description: description, file: file, line: line)
            recipe(testCase.input) { actual in
                testable.assert(actual: actual, expected: testCase.expected, description: description, file: testCase.file, line: testCase.line)
                expectation.fulfill(testCase.file, line: Int(testCase.line))
            }
            return expectation
        }

        testable.wait(for: expectations, timeout: timeout, enforceOrder: false, file: file, line: line)
    }
}
