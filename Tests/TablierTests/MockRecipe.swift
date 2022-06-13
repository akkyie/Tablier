@testable import Tablier

final class MockRecipe<Input: Equatable, Output: Equatable>: RecipeType {
    var testCases: [TestCase<Input, Output>] = []
}
