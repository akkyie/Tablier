extension Recipe {
    public struct TestCase {
        let input: Input
        let expected: Output
        var descriptions: [String]
        let file: StaticString
        let line: UInt
    }
}
