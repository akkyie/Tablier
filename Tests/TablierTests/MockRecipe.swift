@testable import Tablier

final class MockRecipe<Input, Output: Equatable>: RecipeType {
    var testCases: [TestCase<Input, Output>] = []
}
