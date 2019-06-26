import Foundation
import XCTest

@testable import Tablier

class MockExpectation: XCTestExpectationProtocol {
    let didCallFulfill: () -> Void

    init(didCallFulfill: @escaping () -> Void) {
        self.didCallFulfill = didCallFulfill
    }

    func fulfill() {
        didCallFulfill()
    }

    func fulfill(_ file: StaticString, line: Int) {
        didCallFulfill()
    }
}

final class MockTestCase: XCTestCaseProtocol {
    typealias Expectation = MockExpectation

    let didCallExpectation: () -> Void
    let didCallWait: () -> Void
    let didCallFulfill: () -> Void

    init(
        didCallExpectation: @escaping () -> Void = {},
        didCallWait: @escaping () -> Void = {},
        didCallFulfill: @escaping () -> Void = {}
    ) {
        self.didCallExpectation = didCallExpectation
        self.didCallWait = didCallWait
        self.didCallFulfill = didCallFulfill
    }

    func wait(for expectations: [MockExpectation], timeout: TimeInterval, enforceOrder: Bool) {
        didCallWait()
    }

    func wait(
        for expectations: [Expectation], timeout: TimeInterval, enforceOrder: Bool,
        file: StaticString, line: Int
    ) {
        didCallWait()
    }

    func expectation(description: String) -> MockExpectation {
        didCallExpectation()
        return MockExpectation(didCallFulfill: didCallFulfill)
    }

    func expectation(description: String, file: StaticString, line: Int) -> MockExpectation {
        didCallExpectation()
        return MockExpectation(didCallFulfill: didCallFulfill)
    }
}
