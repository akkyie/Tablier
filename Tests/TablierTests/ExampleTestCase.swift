import XCTest
import Tablier

fileprivate struct Foo: Equatable, Codable {
    let int: Int
}

class ExampleTestCase: XCTestCase {
    func testJSONDecoder() {
        let scenario = Scenario<String, Foo> { input in
            let decoder = JSONDecoder()
            return try decoder.decode(Foo.self, from: input.data(using: .utf8)!)
        }

        scenario.when(input: "{\"int\": 123}").expect(Foo(int: 123))

        scenario.assert(with: self)
    }
}
