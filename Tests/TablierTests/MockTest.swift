import Foundation
import XCTest

@testable import Tablier

struct MockExpectation: Fulfillable {
    let fulfillClosure: () -> Void

    func fulfill(_ file: StaticString, line: Int) {
        fulfillClosure()
    }
}

final class MockTest: Testable {
    typealias Expectation = MockExpectation

    let didCallFail: () -> Void
    let didCallExpectation: () -> Void
    let didCallWait: () -> Void
    let didCallFulfill: () -> Void

    init(
        didCallFail: @escaping () -> Void = {},
        didCallExpectation: @escaping () -> Void = {},
        didCallWait: @escaping () -> Void = {},
        didCallFulfill: @escaping () -> Void = {}
    ) {
        self.didCallFail = didCallFail
        self.didCallExpectation = didCallExpectation
        self.didCallWait = didCallWait
        self.didCallFulfill = didCallFulfill
    }

    func fail(description: String, file: StaticString, line: UInt) {
        didCallFail()
    }

    func expectation(description: String, file: StaticString, line: UInt) -> MockExpectation {
        didCallExpectation()

        return MockExpectation { [unowned self] in
            self.didCallFulfill()
        }
    }

    func wait(for expectations: [MockExpectation], timeout: TimeInterval, enforceOrder: Bool,
              file: StaticString, line: UInt) {
        didCallWait()
    }

    func assertionDescription(for actual: Any, expected: Any, descriptions: [String]) -> String {
        return ""
    }

    func errorDescription(for error: Error, expected: Any, descriptions: [String]) -> String {
        return ""
    }
}
