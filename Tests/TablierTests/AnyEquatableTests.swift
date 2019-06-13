@testable import Tablier
import XCTest

fileprivate struct Foo: Equatable {}

final class AnyEquatableTests: XCTestCase {
    func testEquatableConformance() {
        do {
            let a = AnyEquatable(123)
            let b = AnyEquatable(123)
            XCTAssertEqual(a, b)
        }

        do {
            let a = AnyEquatable(123)
            let b = AnyEquatable(456)
            XCTAssertNotEqual(a, b)
        }

        do {
            let a = AnyEquatable(123)
            let b = AnyEquatable("123")
            XCTAssertNotEqual(a, b)
        }

        do {
            // not CustomStringConvertible
            let a = AnyEquatable(Foo())
            let b = AnyEquatable(Foo())
            XCTAssertEqual(a, b)
        }
    }

    func testDescription() {
        // CustomStringConvertible
        XCTAssertEqual(AnyEquatable(Int(123)).description, "123")

        // not CustomStringConvertible
        XCTAssertEqual(AnyEquatable(Foo()).description, "Foo()")
    }
}
