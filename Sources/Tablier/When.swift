public final class When<Input, Output: Equatable> {
    let recipe: AnyRecipe<Input, Output>
    let inputs: [Input]
    let file: StaticString
    let line: UInt
    var descriptions: [String] = []

    init<Recipe: RecipeType>(recipe: Recipe, inputs: [Input], file: StaticString, line: UInt)
    where Recipe.Input == Input, Recipe.Output == Output {
        self.recipe = AnyRecipe(recipe)
        self.inputs = inputs
        self.file = file
        self.line = line
    }

    public func withDescription(_ description: String) -> Self {
        self.descriptions.append(description)
        return self
    }

    @discardableResult
    public func expect(_ expected: Output) -> Expect<Input, Output> {
        return Expect(
            recipe: recipe,
            inputs: inputs,
            expected: expected,
            descriptions: descriptions,
            file: file,
            line: line
        )
    }
}
