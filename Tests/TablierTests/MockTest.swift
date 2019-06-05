import Foundation
import XCTest

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
    let expectationExpectation: XCTestExpectation?
    let fulfillExpectation: XCTestExpectation?
    let waitExpectation: XCTestExpectation?

    init() {
        self.assertExpectation = nil
        self.expectationExpectation = nil
        self.fulfillExpectation = nil
        self.waitExpectation = nil
    }

    init(
        assertExpectation: XCTestExpectation,
        expectationExpectation: XCTestExpectation,
        fulfillExpectation: XCTestExpectation,
        waitExpectation: XCTestExpectation
    ) {
        self.assertExpectation = assertExpectation
        self.expectationExpectation = expectationExpectation
        self.fulfillExpectation = fulfillExpectation
        self.waitExpectation = waitExpectation
    }

    func assert<Output>(
        actual: Result<Output, TablierError>,
        expected: Output,
        description: String,
        file: StaticString,
        line: UInt
    ) where Output : Equatable {
        assertExpectation?.fulfill()
    }

    func expectation(description: String, file: StaticString, line: UInt) -> MockExpectation {
        expectationExpectation?.fulfill()
        return MockExpectation(fulfillExpectation: fulfillExpectation)
    }

    func wait(for expectations: [MockExpectation], timeout: TimeInterval, enforceOrder: Bool, file: StaticString, line: UInt) {
        waitExpectation?.fulfill()
    }
}
