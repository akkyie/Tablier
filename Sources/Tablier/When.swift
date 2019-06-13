#if canImport(Result)
import Result
#endif

extension Recipe {
    public final class When {
        let recipe: AnyRecipe<Input, Output>
        let input: Input
        var testCases: [TestCase<Input, Output>] = []

        init<Recipe: RecipeType>(recipe: Recipe, input: Input) where Recipe.Input == Input, Recipe.Output == Output {
            self.recipe = AnyRecipe(recipe)
            self.input = input
        }

        deinit {
            recipe.testCases.append(contentsOf: testCases)
        }

        @discardableResult
        public func expect<T: Equatable>(_ keyPath: KeyPath<Output, T>, _ expected: T,
                                         description makeDescription: @autoclosure () -> String = "",
                                         file: StaticString = #file, line: UInt = #line) -> Self {
            // swiftlint:disable todo
            // TODO: currently the description of a KeyPath gives us not much useful information, so ignore it for now
            // and SwiftLint is disabled here because it's unpredictable when this TODO is removed

            let testCase = TestCase<Input, Output>(
                input: input,
                filter: { output in AnyEquatable(output[keyPath: keyPath]) },
                expected: AnyEquatable(expected),
                description: makeDescription(),
                // keyPathDescription: "\(keyPath)",
                file: file,
                line: line
            )

            testCases.append(testCase)
            return self
        }

        @discardableResult
        public func expect(
            _ expected: Output,
            description makeDescription: @autoclosure () -> String = "",
            file: StaticString = #file,
            line: UInt = #line
        ) -> Self {
            return expect(\.self, expected, description: makeDescription(), file: file, line: line)
        }

        public func omit() {
            testCases = []
        }
    }
}
