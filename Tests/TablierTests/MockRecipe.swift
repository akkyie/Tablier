@testable import Tablier

final class MockRecipe<Input: Equatable, Output: Equatable>: RecipeType {
    var testCases: [Recipe<Input, Output>.TestCase] = []
}
