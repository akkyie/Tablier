import struct Foundation.TimeInterval

public typealias Testable = Assertable & Waitable

public protocol Fulfillable {
    func fulfill(_ file: StaticString, line: Int)
}

public protocol Assertable {
    func fail(description: String, file: StaticString, line: UInt)
}

public protocol Waitable {
    associatedtype Expectation: Fulfillable

    func expectation(description: String, file: StaticString, line: UInt) -> Expectation
    func wait(for expectations: [Expectation], timeout: TimeInterval, enforceOrder: Bool,
              file: StaticString, line: UInt)
}
