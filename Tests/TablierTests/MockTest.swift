import Foundation
import XCTest

#if canImport(Result)
import Result
#endif

@testable import Tablier

struct MockExpectation: Fulfillable {
    let fulfillExpectation: XCTestExpectation?

    func fulfill(_ file: StaticString, line: Int) {
        fulfillExpectation?.fulfill()
    }
}

struct MockTest: Testable {
    typealias Expectation = MockExpectation

    let assertExpectation: XCTestExpectation?
    let failExpectation: XCTestExpectation?
    let expectationExpectation: XCTestExpectation?
    let fulfillExpectation: XCTestExpectation?
    let waitExpectation: XCTestExpectation?

    init() {
        self.assertExpectation = nil
        self.failExpectation = nil
        self.expectationExpectation = nil
        self.fulfillExpectation = nil
        self.waitExpectation = nil
    }

    init(assertExpectation: XCTestExpectation,
         failExpectation: XCTestExpectation,
         expectationExpectation: XCTestExpectation,
         fulfillExpectation: XCTestExpectation,
         waitExpectation: XCTestExpectation) {
        self.assertExpectation = assertExpectation
        self.failExpectation = failExpectation
        self.expectationExpectation = expectationExpectation
        self.fulfillExpectation = fulfillExpectation
        self.waitExpectation = waitExpectation
    }

    func assert(actual: AnyEquatable, expected: AnyEquatable,
                description: String, file: StaticString, line: UInt) {
        assertExpectation?.fulfill()
    }

    func fail(error: AnyError, expected: AnyEquatable,
              description: String, file: StaticString, line: UInt) {
        failExpectation?.fulfill()
    }

    func expectation(description: String, file: StaticString, line: UInt) -> MockExpectation {
        expectationExpectation?.fulfill()
        return MockExpectation(fulfillExpectation: fulfillExpectation)
    }

    func wait(for expectations: [MockExpectation], timeout: TimeInterval, enforceOrder: Bool,
              file: StaticString, line: UInt) {
        waitExpectation?.fulfill()
    }
}
