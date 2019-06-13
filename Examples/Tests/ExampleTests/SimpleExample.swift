import XCTest
import Tablier

@testable import Example

/// SimpleExample
final class PluralizeTests: XCTestCase {
    func testPluralize() {
        let recipe = Recipe<String, String>(sync: { input in
            return try pluralize(word: input)
        })

        recipe.assert(with: self) { when in
            when("apple").expect("apples")
            when("banana").expect("bananas")
            when("chocolate").expect("chocolates")

            when("leaf").expect("leaves", description: "end with -f")
            when("knife").expect("knives", description: "end with -fe")
            when("tomato").expect("tomatoes", description: "end with -o")

            // uncomment to see error
            // when("foot").expect("feet", description: "irregular one")
        }
    }
}
