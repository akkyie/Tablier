import XCTest
import Tablier

@testable import Example

final class ExamplesTests: XCTestCase {
    func testPluralize() {
        let recipe = Recipe<String, String>(sync: { input in
            return try pluralize(word: input)
        })

        recipe.assert(with: self) { when in
            when("apple").expect("apples")
            when("banana").expect("bananas")
            when("chocolate").expect("chocolates")

            when("leaf").expect("leaves").with(description: "end with -f")
            when("knife").expect("knives").with(description: "end with -fe")
            when("tomato").expect("tomatoes").with(description: "end with -o")

            // when("foot").expect("feet").with(description: "irregular!")
        }
    }
}
