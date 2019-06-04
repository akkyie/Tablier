import struct Foundation.TimeInterval

#if canImport(Result)
    import Result
#endif

public typealias Testable = Assertable & Waitable

public protocol Fullfillable {
    func fulfill(_ file: StaticString, line: Int)
}

public protocol Assertable {
    func assert<Output: Equatable>(actual: Result<Output, AnyError>, expected: Output, file: StaticString, line: UInt)
}

public protocol Waitable {
    associatedtype Expectation: Fullfillable

    func expectation(description: String, file: StaticString, line: UInt) -> Expectation
    func wait(for expectations: [Expectation], timeout: TimeInterval, enforceOrder: Bool, file: StaticString, line: UInt)
}
