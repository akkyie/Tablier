extension Recipe {
    public final class Expect {
        let recipe: AnyRecipe<Input, Output>
        var testCase: TestCase<Input, Output>

        init<Recipe: RecipeType>(recipe: Recipe, input: Input, expected: Output, file: StaticString, line: UInt)
            where Recipe.Input == Input, Recipe.Output == Output
        {
            self.recipe = AnyRecipe(recipe)
            self.testCase = TestCase(input: input, expected: expected, description: "", file: file, line: line)
        }

        public func with(description: String) {
            testCase.description = description
        }

        deinit {
            recipe.testCases.append(testCase)
        }
    }
}
