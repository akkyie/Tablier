extension Recipe {
    public final class Expecter {
        let recipe: AnyRecipe<Input, Output>

        init(recipe: AnyRecipe<Input, Output>) {
            self.recipe = recipe
        }

        public func when(_ inputs: Input..., file: StaticString = #file, line: UInt = #line) -> When {
            return When(recipe: recipe, inputs: inputs, file: file, line: line)
        }
    }
}
