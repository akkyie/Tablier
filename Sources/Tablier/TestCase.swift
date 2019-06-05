public struct TestCase<Input, Output> {
    let input: Input
    let expected: Output
    var description: String
    let file: StaticString
    let line: UInt
}
