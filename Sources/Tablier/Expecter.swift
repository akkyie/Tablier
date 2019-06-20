public final class Expecter<Input, Output: Equatable> {
    let recipe: AnyRecipe<Input, Output>

    init(recipe: AnyRecipe<Input, Output>) {
        self.recipe = recipe
    }

    public func when(_ inputs: Input..., file: StaticString = #file, line: UInt = #line) -> When<Input, Output> {
        return When(recipe: recipe, inputs: inputs, file: file, line: line)
    }
}
