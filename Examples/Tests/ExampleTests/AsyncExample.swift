import XCTest
import Tablier

@testable import Example

/// Async Example
final class AsyncTests: XCTestCase {
    func testAsync() {
        let recipe = Recipe<String, String>(async: { input, completion, _, _ in
            asyncEcho(input) { output in
                completion(output, nil)
            }
        })

        recipe.assert(with: self) {
            $0.when("0").expect("0")
            $0.when("1").expect("1")
            $0.when("2").expect("2")
            $0.when("3").expect("3")
            $0.when("4").expect("4")
            $0.when("5").expect("5")
            $0.when("6").expect("6")
            $0.when("7").expect("7")
            $0.when("8").expect("8")
            $0.when("9").expect("9")
        }

        // should end in 1 sec.
    }
}
