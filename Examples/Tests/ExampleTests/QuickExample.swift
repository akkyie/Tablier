import XCTest
import Quick
import Tablier

@testable import Example

/// Example with Quick
final class QuickTests: QuickSpec {
    override func spec() {
        describe("pluralize") {
            let recipe = Recipe<String, String>(sync: { input in
                return try pluralize(word: input)
            })

            // `it` should be outside of `recipe.assert`
            it("should return correct plurals") {
                recipe.assert(with: self) { t in
                    t.when("apple").expect("apples")
                    t.when("banana").expect("bananas")
                    t.when("chocolate").expect("chocolates")

                    t.when("leaf").expect("leaves").withDescription("end with -f")
                    t.when("knife").expect("knives").withDescription("end with -fe")
                    t.when("tomato").expect("tomatoes").withDescription("end with -o")

                    // Remove omit() to see how it fails
                    t.when("foot").expect("feet").withDescription("irregular one").omit()
                }
            }
        }
    }
}
