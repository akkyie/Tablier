extension Recipe {
    public final class Expect {
        var testCases: [TestCase]
        var testCase: TestCase

        init(testCases: inout [TestCase], input: Input, expected: Output, file: StaticString, line: UInt) {
            self.testCases = testCases
            self.testCase = TestCase(input: input, expected: expected, description: "", file: file, line: line)
        }

        func with(description: String) {
            testCase.description = description
        }

        deinit {
            testCases.append(testCase)
        }
    }
}
