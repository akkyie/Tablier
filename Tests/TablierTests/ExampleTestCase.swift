import XCTest
import Tablier

class ExampleTestCase: XCTestCase {
    func testStringToInt() {
        let scenario = Scenario<String, Int?>(description: "Int.init?(String)") { input in
            Int(input)
        }

        scenario.when(input: "1").expect(1)
        scenario.when(input: "123").expect(123)
        scenario.when(input: "-1").expect(-1)
        scenario.when(input: "-123").expect(-123)

        scenario.when(input: "").expect(nil)

        scenario.when(input: "A").expect(0xA)

        scenario.assert(with: self)
    }
}
