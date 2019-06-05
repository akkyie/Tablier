extension Recipe {
    public final class When {
        let recipe: AnyRecipe<Input, Output>
        let input: Input

        init<Recipe: RecipeType>(recipe: Recipe, input: Input) where Recipe.Input == Input, Recipe.Output == Output {
            self.recipe = AnyRecipe(recipe)
            self.input = input
        }

        @discardableResult
        public func expect(_ expected: Output, file: StaticString = #file, line: UInt = #line) -> Expect {
            return Expect(recipe: recipe, input: input, expected: expected, file: file, line: line)
        }
    }
}
