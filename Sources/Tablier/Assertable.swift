import struct Foundation.TimeInterval

#if canImport(Result)
    import Result
#endif

public protocol Fullfillable {
    func fulfill()
}

public protocol Assertable {
    associatedtype Expectation: Fullfillable

    func makeExpectation(description: String) -> Expectation

    func assert<Output: Equatable>(actual: Result<Output, AnyError>, expected: Output, file: StaticString, line: UInt)

    func wait(for expectations: [Expectation], timeout: TimeInterval)
}
