extension Recipe {
    public final class When {
        var testCases: [TestCase]
        let input: Input

        init(testCases: inout [TestCase], recipe: Recipe<Input, Output>, input: Input) {
            self.testCases = testCases
            self.input = input
        }

        @discardableResult
        func expect(_ expected: Output, file: StaticString = #file, line: UInt = #line) -> Expect {
            return Expect(testCases: &testCases, input: input, expected: expected, file: file, line: line)
        }
    }
}
