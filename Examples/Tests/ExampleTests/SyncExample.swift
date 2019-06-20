import XCTest
import Tablier

@testable import Example

/// Sync Example
final class PluralizeTests: XCTestCase {
    func testPluralize() {
        let recipe = Recipe<String, String>(sync: { input in
            return try pluralize(word: input)
        })

        recipe.assert(with: self) {
            $0.when("apple").expect("apples")
            $0.when("banana").expect("bananas")
            $0.when("chocolate").expect("chocolates")

            $0.when("leaf").expect("leaves").withDescription("end with -f")
            $0.when("knife").expect("knives").withDescription("end with -fe")
            $0.when("tomato").expect("tomatoes").withDescription("end with -o")

            // Remove omit() to see how it fails
            $0.when("foot").expect("feet").withDescription("irregular one").omit()
        }
    }
}
