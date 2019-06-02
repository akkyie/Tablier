import struct Foundation.TimeInterval

public protocol Fullfillable {
    func fulfill()
}

public protocol Assertable {
    associatedtype Expectation: Fullfillable

    func makeExpectation(description: String) -> Expectation

    func assert<Output: Equatable>(actual: Output, expected: Output, file: StaticString, line: UInt)

    func wait(for expectations: [Expectation], timeout: TimeInterval)
}
