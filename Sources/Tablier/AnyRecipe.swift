final class AnyRecipe<Input, Output: Equatable>: RecipeType {
    var testCases: [TestCase<Input, Output>] {
        get { return getTestCases() }
        set { setTestCases(newValue) }
    }

    private let getTestCases: () -> [TestCase<Input, Output>]
    private let setTestCases: ([TestCase<Input, Output>]) -> Void

    init<Recipe: RecipeType>(_ recipe: Recipe) where Recipe.Input == Input, Recipe.Output == Output {
        self.getTestCases = { [unowned recipe] in recipe.testCases }
        self.setTestCases = { [unowned recipe] in recipe.testCases = $0 }
    }
}
