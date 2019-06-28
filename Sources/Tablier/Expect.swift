extension Recipe {
    public final class Expect {
        let recipe: AnyRecipe<Input, Output>
        var inputs: [Input]
        let expected: Output
        let file: StaticString
        let line: UInt
        var descriptions: [String] = []

        init(recipe: AnyRecipe<Input, Output>, inputs: [Input], expected: Output,
             descriptions: [String], file: StaticString, line: UInt) {
            self.recipe = recipe
            self.inputs = inputs
            self.expected = expected
            self.descriptions = descriptions
            self.file = file
            self.line = line
        }

        deinit {
            let testCases = inputs.map { input in
                TestCase(
                    input: input,
                    expected: expected,
                    descriptions: descriptions,
                    file: file,
                    line: line
                )
            }
            recipe.testCases.append(contentsOf: testCases)
        }

        @discardableResult
        public func withDescription(_ description: String) -> Self {
            descriptions.append(description)
            return self
        }

        public func omit() {
            inputs = []
        }
    }

}
