public struct TestCase<Input, Output> {
    let input: Input
    let filter: (Output) -> AnyEquatable
    let expected: AnyEquatable
    var description: String
    let file: StaticString
    let line: UInt
}
