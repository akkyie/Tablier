final class AnyRecipe<Input, Output: Equatable>: RecipeType {
    var testCases: [Recipe<Input, Output>.TestCase] {
        get { return getTestCases() }
        set { setTestCases(newValue) }
    }

    private let getTestCases: () -> [Recipe<Input, Output>.TestCase]
    private let setTestCases: ([Recipe<Input, Output>.TestCase]) -> Void

    init<Recipe: RecipeType>(_ recipe: Recipe) where Recipe.Input == Input, Recipe.Output == Output {
        self.getTestCases = { [recipe] in recipe.testCases }
        self.setTestCases = { [recipe] in recipe.testCases = $0 }
    }
}
